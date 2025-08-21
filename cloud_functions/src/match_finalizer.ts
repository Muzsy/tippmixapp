import { ApiFootballResultProvider, findFixtureIdByMeta } from './services/ApiFootballResultProvider';
import { calcTicketPayout } from './tickets/payout';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { db } from './lib/firebase';
import { CoinService } from './services/CoinService';
import { getEvaluator, NormalizedResult } from './evaluators';

const provider = new ApiFootballResultProvider();

// After computing tip results for a ticket
async function finalizeTicketAtomic(
  ticketRef: FirebaseFirestore.DocumentReference,
  userRef: FirebaseFirestore.DocumentReference,
  ticketData: any,
) {
  const db = getFirestore();
  await db.runTransaction(async (tx) => {
    const [tSnap] = await Promise.all([tx.get(ticketRef), tx.get(userRef)]);
    const t = tSnap.data();
    if (!t) throw new Error('Ticket not found');
    if (t.processedAt) {
      return; // idempotent exit
    }
    const tips = (ticketData.tips || []).map((x: any) => ({
      market: x.market,
      selection: x.selection,
      result: x.result,
      oddsSnapshot: x.oddsSnapshot,
    }));
    // If any pending remain, do nothing
    if (tips.some((x: any) => x.result === 'pending')) return;
    const payout = calcTicketPayout(ticketData.stake, tips);
    const status = tips.some((x: any) => x.result === 'lost') ? 'lost' : (payout > 0 ? 'won' : 'void');
    // users.balance helyett csak a ticket mezői frissülnek; pénzügy a CoinService-ben
    tx.update(ticketRef, { status, payout, processedAt: new Date(), tips });
  });
}

interface PubSubMessage {
  data?: string;
  attributes?: { [key: string]: string };
}

type JobType = 'kickoff-tracker' | 'result-poller' | 'final-sweep';

export const match_finalizer = async (message: PubSubMessage): Promise<void> => {
  console.log('[match_finalizer] received raw message');
  try { console.log('[match_finalizer] payload:', JSON.stringify(message?.data || {})); } catch {}
  const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
  const { job }: { job: JobType } = JSON.parse(payloadStr);

  // 1) Collect pending tickets across all users via collectionGroup
  // Tickets are stored under /tickets/{uid}/tickets/{ticketId}
  const ticketsSnap = await db
    .collectionGroup('tickets')
    .where('status', '==', 'pending')
    .limit(200)
    .get();

  if (ticketsSnap.empty) {
    console.log('[match_finalizer] no pending tickets – exit');
    return;
  }
  console.log('[match_finalizer] found %d pending tickets', ticketsSnap.size);

  // Gather unique eventIds from tips[] arrays
  const eventIdSet = new Set<string>();
  for (const doc of ticketsSnap.docs) {
    const tips = (doc.get('tips') as any[]) || [];
    for (const t of tips) {
      if (t && typeof t.eventId === 'string' && t.eventId.trim()) {
        eventIdSet.add(t.eventId.trim());
      }
    }
  }

  const eventIds = Array.from(eventIdSet);
  console.log(`[match_finalizer] found ${eventIds.length} unique eventIds`);

  // 2) Fetch scores
  let scores;
  try {
    scores = await provider.getScores(eventIds);
  } catch (err) {
    console.error('[match_finalizer] ResultProvider error', err);
    throw err; // message will be retried / DLQ
  }

  // 3) Map of results with normalized fields
  const resultMap = new Map<string, NormalizedResult>();
  scores.forEach(r => {
    resultMap.set(r.id, {
      completed: r.completed,
      scores: r.scores,
      home_team: r.home_team,
      away_team: r.away_team,
      winner: r.winner,
    });
  });

  // 4) Evaluate each ticket based on its tips and finalize atomically
  for (const snap of ticketsSnap.docs) {
    const tipsRaw = (snap.get('tips') as any[]) || [];
    if (!tipsRaw.length) continue;

    const pendingTipUpdates: { index: number; fixtureId: number }[] = [];
    const tipResults: any[] = [];
    for (let ti = 0; ti < tipsRaw.length; ti++) {
      const t = tipsRaw[ti];
      const rid0 = t?.fixtureId ?? t?.eventId;
      const rid = rid0 ? String(rid0) : '';
      let res = rid ? resultMap.get(rid) : undefined;
      if (!res && t?.eventName && t?.startTime) {
        try {
          const found = await findFixtureIdByMeta({
            eventName: String(t.eventName),
            startTime: new Date(String(t.startTime)).toISOString(),
          });
          if (found?.id) {
            res = resultMap.get(String(found.id));
            pendingTipUpdates.push({ index: ti, fixtureId: Number(found.id) });
          }
        } catch (e) {
          console.warn('[match_finalizer] fixture resolver failed', e);
        }
      }
      const pick = (t?.outcome ?? '').trim();
      const marketKey = t?.marketKey ?? t?.market ?? 'h2h';
      const evaluator = getEvaluator(String(marketKey));
      if (!res || !evaluator) {
        tipResults.push({
          ...t,
          market: String(marketKey).toUpperCase(),
          selection: pick,
          result: 'pending',
          oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
        });
        continue;
      }
      const tipInput = {
        marketKey: String(marketKey),
        selection: pick,
        odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
      };
      const outcome = evaluator.evaluate(tipInput, res);
      tipResults.push({
        ...t,
        market: String(marketKey).toUpperCase(),
        selection: pick,
        result: outcome,
        oddsSnapshot: tipInput.odds,
      });
    }

    const uid = (snap.get('userId') || (snap.ref.parent?.parent?.id));
    await finalizeTicketAtomic(
      snap.ref,
      db.collection('users').doc(String(uid)),
      { stake: snap.get('stake'), tips: tipResults },
    );
    if (pendingTipUpdates.length) {
      const updates: any = {};
      for (const u of pendingTipUpdates) {
        updates[`tips.${u.index}.fixtureId`] = u.fixtureId;
      }
      await snap.ref.update(updates);
    }
    // Wallet credit via CoinService (idempotens – ledger kulcs: ticketId)
    {
      const payout = calcTicketPayout(snap.get('stake'), tipResults);
      if (uid && payout > 0) {
        const coins = Math.round(payout);
        try {
          await new CoinService().credit(String(uid), coins, snap.id);
        } catch (e) {
          console.error('[match_finalizer] wallet credit failed', e);
        }
      }
    }
  }

  // zárás után:
  console.log('[match_finalizer] finalize done for batch');
};

