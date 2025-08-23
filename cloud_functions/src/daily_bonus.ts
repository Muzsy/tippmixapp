import '../global';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as logger from 'firebase-functions/logger';
import { db } from './lib/firebase';
import { CoinService } from './services/CoinService';

export const daily_bonus = onSchedule({ schedule: '5 0 * * *', timeZone: 'Europe/Budapest' }, async () => {
  const PAGE = 200;
  const bonusCoins = 50;
  const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const refId = `daily_bonus_${today}`;
  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  let total = 0;
  while (true) {
    const q = lastDoc
      ? db.collection('users').orderBy('__name__').startAfter(lastDoc.id).limit(PAGE)
      : db.collection('users').orderBy('__name__').limit(PAGE);
    const snap = await q.get();
    if (snap.empty) break;
    for (const doc of snap.docs) {
      const uid = doc.id;
      try {
        await new CoinService().credit(uid, bonusCoins, refId, 'daily_bonus');
        total++;
      } catch (e: any) {
        logger.error('daily_bonus.credit_failed', { uid, refId, error: e?.message || String(e) });
      }
    }
    lastDoc = snap.docs[snap.docs.length - 1];
    logger.info('daily_bonus.page_done', { processed: total });
  }
  logger.info('daily_bonus.completed', { total });
});
