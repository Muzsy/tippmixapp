import { ApiFootballResultProvider, findFixtureIdByMeta } from './services/ApiFootballResultProvider';
import { calcTicketPayout } from './tickets/payout';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { db } from './lib/firebase';
import { PubSub } from '@google-cloud/pubsub';
import { CoinService } from './services/CoinService';
import { getEvaluator, NormalizedResult } from './evaluators';

const provider = new ApiFootballResultProvider();

const pubsub = new PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';
const DLQ_TOPIC = process.env.DLQ_TOPIC || 'match_finalizer-dlq';
const BATCH_SIZE = Number(process.env.FINALIZER_BATCH_SIZE || 200);
const MAX_BATCHES = Number(process.env.FINALIZER_MAX_BATCHES || 3);

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

export const match_finalizer = async (message: PubSubMessage): Promise<'OK'|'RETRY'|'DLQ'> => {
  const attempt = Number((message?.attributes?.attempt as string) || '0');
  logger.info('match_finalizer.handle', { hasData: !!message?.data, attempt, attrKeys: Object.keys(message.attributes || {}) });
  let job: JobType | undefined;
  try {
    const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
    ({ job } = JSON.parse(payloadStr) as { job: JobType });

    // Batch pagination over pending tickets
    let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined = undefined;
    let batches = 0;
    let anyProcessed = false;
    let morePossible = false;

    while (batches < MAX_BATCHES) {
      let q = db.collectionGroup('tickets')
        .where('status', '==', 'pending')
        .orderBy('__name__')
        .limit(BATCH_SIZE) as FirebaseFirestore.Query<FirebaseFirestore.DocumentData>;

      if (lastDoc) {
        q = q.startAfter(lastDoc);
      }
      const ticketsSnap = await q.get();
      if (ticketsSnap.empty) {
        logger.info('match_finalizer.no_pending_batch', { batch: batches });
        break;
      }
      anyProcessed = true;
      if (ticketsSnap.size === BATCH_SIZE) {
        morePossible = true;
      }
      logger.info('match_finalizer.pending_tickets_batch', { batch: batches, count: ticketsSnap.size });

      // Gather unique eventIds from this batch's tips[] arrays
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
      logger.info('match_finalizer.unique_events_batch', { batch: batches, count: eventIds.length });

      // 2) Fetch scores
      let scores;
      try {
        scores = await provider.getScores(eventIds);
      } catch (err) {
        logger.error('match_finalizer.result_provider_error', { error: err });
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
              logger.warn('match_finalizer.fixture_resolver_failed', { error: e });
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
              logger.error('match_finalizer.wallet_credit_failed', { error: e, uid: String(uid), ticketId: snap.id });
            }
          }
        }
      } // for ticketsSnap.docs

      // end of batch processing for this page
      lastDoc = ticketsSnap.docs[ticketsSnap.docs.length - 1];
      batches += 1;
    } // while

    if (morePossible) {
      await pubsub.topic(RESULT_TOPIC).publishMessage({
        data: Buffer.from(JSON.stringify({ job })),
        attributes: { attempt: '0' }
      });
      logger.info('match_finalizer.enqueue_next_batch', { next: true });
    }

    if (!anyProcessed) {
      logger.info('match_finalizer.no_pending');
    }
    logger.info('match_finalizer.finalize_done');
    return 'OK';
  } catch (e: any) {
    logger.error('match_finalizer.handle_error', { error: e?.message || String(e), attempt });
    try {
      if (attempt >= 2) {
        await pubsub.topic(DLQ_TOPIC).publishMessage({ data: Buffer.from(JSON.stringify({ job })), attributes: { attempt: String(attempt) } });
        logger.error('match_finalizer.sent_to_dlq', { attempt });
        return 'DLQ';
      } else {
        await pubsub.topic(RESULT_TOPIC).publishMessage({ data: Buffer.from(JSON.stringify({ job })), attributes: { attempt: String(attempt + 1) } });
        logger.warn('match_finalizer.requeued', { nextAttempt: attempt + 1 });
        return 'RETRY';
      }
    } catch (pubErr) {
      logger.error('match_finalizer.requeue_failed', { error: String(pubErr) });
    }
    return 'RETRY';
  }
};

