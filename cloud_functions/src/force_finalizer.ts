import '../global';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { PubSub } from '@google-cloud/pubsub';

const pubsub = new PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';

export const force_finalizer = onCall(async (request) => {
  const ctx: any = request;
  if (!ctx.auth) throw new HttpsError('unauthenticated', 'Auth required');

  const isAdmin = Boolean((ctx.auth.token as any)?.admin);
  const devOverride = Boolean(request.data?.devOverride);
  const allowDev =
    process.env.ALLOW_DEV_FORCE_FINALIZER === 'true' && devOverride;

  if (!isAdmin && !allowDev) {
    throw new HttpsError('permission-denied', 'Admin only');
  }

  const payload = {
    type: 'final-sweep',
    requestedBy: ctx.auth.uid,
    ts: Date.now(),
  };

  await pubsub.topic(RESULT_TOPIC).publishMessage({
    data: Buffer.from(JSON.stringify(payload), 'utf8'),
    attributes: { attempt: '0' },
  });

  return { status: 'OK' };
});
