import * as functions from 'firebase-functions';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

export const daily_bonus = functions
  .region('europe-central2')
  .pubsub.schedule('5 0 * * *')
  .timeZone('Europe/Budapest')
  .onRun(async () => {
    const usersSnap = await db.collection('users').get();
    const batch = db.batch();

    usersSnap.docs.forEach((doc) => {
      const userId = doc.id;
      const logRef = db
        .collection('users')
        .doc(userId)
        .collection('coin_logs')
        .doc();
      batch.set(logRef, {
        userId,
        amount: 50,
        type: 'credit',
        reason: 'daily_bonus',
        transactionId: logRef.id,
        timestamp: FieldValue.serverTimestamp(),
        description: 'Daily bonus',
      });
    });

    await batch.commit();
  });
