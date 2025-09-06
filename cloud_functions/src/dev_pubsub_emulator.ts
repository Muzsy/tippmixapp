import '../global';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { PubSub } from '@google-cloud/pubsub';
import { match_finalizer } from './match_finalizer';

const pubsub = new PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';

// Publishes a finalize message to the result-check topic (or runs inline in dev)
export const dev_publish_finalize = onCall(async (request) => {
  const ctx: any = request;
  if (!ctx.auth) throw new HttpsError('unauthenticated', 'Auth required');
  const fixtureId = request.data?.fixtureId;
  if (!fixtureId) throw new HttpsError('invalid-argument', 'fixtureId required');

  if (process.env.USE_INLINE_FINALIZER === 'true') {
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId }), 'utf8').toString('base64'),
      attributes: { attempt: '0' },
    } as any);
    return { status: 'OK_INLINE' };
  }

  await pubsub.topic(RESULT_TOPIC).publishMessage({
    data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId }), 'utf8'),
    attributes: { attempt: '0' },
  });
  return { status: 'OK' };
});

// Simulates a scheduler diag-check kick
export const dev_scheduler_kick = onCall(async (request) => {
  const ctx: any = request;
  if (!ctx.auth) throw new HttpsError('unauthenticated', 'Auth required');
  if (process.env.USE_INLINE_FINALIZER === 'true') {
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ type: 'diag-check', ts: Date.now() }), 'utf8').toString('base64'),
      attributes: { attempt: '0' },
    } as any);
    return { status: 'OK_INLINE' };
  }
  await pubsub.topic(RESULT_TOPIC).publishMessage({
    data: Buffer.from(JSON.stringify({ type: 'diag-check', ts: Date.now() }), 'utf8'),
    attributes: { attempt: '0' },
  });
  return { status: 'OK' };
});

