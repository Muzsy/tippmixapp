import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from './lib/firebase';
import { CoinService } from './services/CoinService';

export const daily_bonus = onSchedule(
  { schedule: '5 0 * * *', timeZone: 'Europe/Budapest' },
  async () => {
    const usersSnap = await db.collection('users').get();
    const bonusCoins = 50;
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const refId = `daily_bonus_${today}`;

    for (const doc of usersSnap.docs) {
      const uid = doc.id;
      await new CoinService().credit(uid, bonusCoins, refId);
    }
  }
);
