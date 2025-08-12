import { ApiFootballResultProvider } from './services/ApiFootballResultProvider';
import { CoinService } from './services/CoinService';

import { db } from './lib/firebase';
import { FieldValue } from 'firebase-admin/firestore';
const resultProvider = new ApiFootballResultProvider();
const coinService = new CoinService();

interface PubSubMessage {
  data?: string;
  attributes?: { [key: string]: string };
}

type JobType = 'kickoff-tracker' | 'result-poller' | 'final-sweep';

export const match_finalizer = async (message: PubSubMessage): Promise<void> => {
  const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
  const { job }: { job: JobType } = JSON.parse(payloadStr);

  console.log(`[match_finalizer] received job: ${job}`);

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
    if (!r.completed || !r.scores) {
      resultMap.set(r.id, { completed: false });
      return;
    }
    const winner = r.scores.home > r.scores.away ? r.home_team : r.away_team;
    resultMap.set(r.id, { completed: true, winner });
  });

  // 4) Evaluate each ticket based on its tips
  const batch = db.batch();
  for (const snap of ticketsSnap.docs) {
    const tips = (snap.get('tips') as any[]) || [];
    if (!tips.length) continue;

    let hasPending = false;
    let hasLost = false;

    for (const t of tips) {
      const rid = t?.eventId;
      const pick = (t?.outcome ?? '').trim();
      if (!rid || !resultMap.has(rid)) {
        hasPending = true;
        continue;
      }
      const { completed, winner } = resultMap.get(rid)!;
      if (!completed || !winner) {
        hasPending = true;
        continue;
      }
      if (winner !== pick) {
        hasLost = true;
      }
    }

    let newStatus: 'pending' | 'won' | 'lost' = 'pending';
    if (hasLost) newStatus = 'lost';
    else if (!hasPending) newStatus = 'won';

    if (newStatus !== 'pending') {
      batch.update(snap.ref, {
        status: newStatus,
        updatedAt: FieldValue.serverTimestamp(),
      });
      if (newStatus === 'won') {
        await coinService.credit(
          snap.get('uid'),
          snap.get('potentialProfit'),
          snap.id,
        );
      }
    }
  }

  await batch.commit();
  console.log('[match_finalizer] batch commit done');
};

