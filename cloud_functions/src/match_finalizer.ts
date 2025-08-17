import { ApiFootballResultProvider } from './services/ApiFootballResultProvider';
import { calcTicketPayout } from './tickets/payout';
import { getFirestore } from 'firebase-admin/firestore';

import { db } from './lib/firebase';
const resultProvider = new ApiFootballResultProvider();

// After computing tip results for a ticket
async function finalizeTicketAtomic(
  ticketRef: FirebaseFirestore.DocumentReference,
  userRef: FirebaseFirestore.DocumentReference,
  ticketData: any,
) {
  const db = getFirestore();
  await db.runTransaction(async (tx) => {
    const [tSnap, uSnap] = await Promise.all([tx.get(ticketRef), tx.get(userRef)]);
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
    const balance = (uSnap.data()?.balance ?? 0) + payout;
    tx.update(userRef, { balance });
    tx.update(ticketRef, { status, payout, processedAt: new Date(), tips });
  });
}

interface PubSubMessage {
  data?: string;
  attributes?: { [key: string]: string };
}

type JobType = 'kickoff-tracker' | 'result-poller' | 'final-sweep';

export const match_finalizer = async (message: PubSubMessage): Promise<void> => {
  const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
  const { job }: { job: JobType } = JSON.parse(payloadStr);

  console.log(`[match_finalizer] received job: ${job}`);

  // 1) Collect pending tickets in root collection
  const ticketsSnap = await db
    .collection('tickets')
    .where('status', '==', 'pending')
    .limit(200)
    .get();

  if (ticketsSnap.empty) {
    console.log('[match_finalizer] no pending tickets – exit');
    return;
  }

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
    scores = await resultProvider.getScores(eventIds);
  } catch (err) {
    console.error('[match_finalizer] ResultProvider error', err);
    throw err; // message will be retried / DLQ
  }

  // 3) Map of results with winner name
  const resultMap = new Map<string, { completed: boolean; winner?: string }>();
  scores.forEach(r => {
    resultMap.set(r.id, { completed: r.completed, winner: r.winner });
  });

  // 4) Evaluate each ticket based on its tips and finalize atomically
  for (const snap of ticketsSnap.docs) {
    const tipsRaw = (snap.get('tips') as any[]) || [];
    if (!tipsRaw.length) continue;

    const tipResults = tipsRaw.map((t: any) => {
      const rid = t?.eventId;
      const pick = (t?.outcome ?? '').trim();
      const res = rid ? resultMap.get(rid) : undefined;
      if (!res || !res.completed || !res.winner) {
        return { ...t, market: t.marketKey, selection: pick, result: 'pending', oddsSnapshot: t.odds };
      }
      const result = res.winner === pick ? 'won' : 'lost';
      return { ...t, market: t.marketKey, selection: pick, result, oddsSnapshot: t.odds };
    });

    await finalizeTicketAtomic(
      snap.ref,
      db.collection('users').doc(snap.get('userId')),
      { stake: snap.get('stake'), tips: tipResults },
    );
  }

  console.log('[match_finalizer] ticket finalization loop done');
};

