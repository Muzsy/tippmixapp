import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { PubSub } from '@google-cloud/pubsub';

const pubsub = new PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';

export const finalize_publish = onRequest({ timeoutSeconds: 120 }, async (req, res) => {
  try {
    const token = req.header('x-admin-token');
    const expected = process.env.BACKFILL_TOKEN; // reuse same admin token for simplicity
    if (expected && token !== expected) {
      res.status(403).send('Forbidden');
      return;
    }

    const body = (req.method === 'POST' ? req.body : undefined) || {};
    const single = req.query.fixtureId as string | undefined;
    const many: Array<string | number> = Array.isArray(body.fixtureIds) ? body.fixtureIds : [];

    const ids: string[] = [];
    if (single) ids.push(String(single));
    for (const x of many) if (x != null) ids.push(String(x));

    if (!ids.length) {
      res.status(400).json({ ok: false, error: 'Missing fixtureId(s)' });
      return;
    }

    let published = 0;
    for (const fid of ids) {
      await pubsub.topic(RESULT_TOPIC).publishMessage({
        data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: fid })),
        attributes: { attempt: '0' },
      });
      published++;
    }
    logger.debug('finalize_publish.published', { count: published });
    res.json({ ok: true, published });
  } catch (e: any) {
    logger.error('finalize_publish.error', { error: e?.message || String(e) });
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});
