import { PubSub } from '@google-cloud/pubsub';
import { ResultProvider } from './services/ResultProvider';
import { CoinService } from './services/CoinService';

import { db } from './lib/firebase';
const resultProvider = new ResultProvider();
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

  // 1) Collect pending tickets + related eventIds
  const ticketsSnap = await db.collection('tickets')
    .where('status', '==', 'pending')
    .get();

  if (ticketsSnap.empty) {
    console.log('[match_finalizer] no pending tickets – exit');
    return;
  }

  const eventIdSet = new Set<string>();
  ticketsSnap.docs.forEach(doc => {
    eventIdSet.add(doc.get('eventId'));
  });

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

  // 3) Map of completed results
  const completedMap = new Map<string, boolean>();
  scores.filter(s => s.completed).forEach(s => completedMap.set(s.id, (s.scores?.home || 0) > (s.scores?.away || 0)));

  // 4) Iterate over tickets and update if completed
  const batch = db.batch();
  ticketsSnap.docs.forEach(doc => {
    const eventId = doc.get('eventId');
    if (completedMap.has(eventId)) {
      const won = completedMap.get(eventId)!;
      batch.update(doc.ref, {
        status: won ? 'won' : 'lost'
      });
      if (won) {
        coinService.credit(doc.get('uid'), doc.get('potentialProfit'), doc.id);
      }
    }
  });

  await batch.commit();
  console.log('[match_finalizer] batch commit done');
};

