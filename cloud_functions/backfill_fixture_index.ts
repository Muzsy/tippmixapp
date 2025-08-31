import './global';
import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { db } from './src/lib/firebase';
import { upsertFixtureIndex } from './fixtures_index';

export const backfill_fixture_index = onRequest({ timeoutSeconds: 540 }, async (req, res) => {
  const token = req.header('x-admin-token');
  const expected = process.env.BACKFILL_TOKEN;
  if (!expected || token !== expected) {
    res.status(403).send('Forbidden');
    return;
  }

  const limit = Math.max(1, Math.min(Number(req.query.limit) || 5000, 50000));
  const pageSize = Math.max(50, Math.min(Number(req.query.pageSize) || 300, 500));
  let processed = 0;
  let lastSnap: FirebaseFirestore.QueryDocumentSnapshot | undefined = undefined as any;

  while (processed < limit) {
    const base = db.collectionGroup('tickets').orderBy('__name__');
    const q = lastSnap ? base.startAfter(lastSnap).limit(pageSize) : base.limit(pageSize);
    const snap = await q.get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      const data = doc.data() as any;
      const uid = (data.userId as string) || doc.ref.parent?.parent?.id || '';
      const ticketId = doc.id;
      try {
        await upsertFixtureIndex(uid, ticketId, data);
        processed++;
      } catch (e: any) {
        logger.error('backfill_fixture_index.error', { id: ticketId, error: e?.message || String(e) });
      }
      if (processed >= limit) break;
    }

    lastSnap = snap.docs[snap.docs.length - 1];
    if (snap.size < pageSize) break;
  }

  res.json({ ok: true, processed });
});
