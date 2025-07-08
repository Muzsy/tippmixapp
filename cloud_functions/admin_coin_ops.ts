import * as functions from 'firebase-functions';
import { getApps, initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Csak egyszer engedjük inicializálni
if (!getApps().length) {
  initializeApp({ credential: applicationDefault() });
}

const db = getFirestore();

export const admin_coin_ops = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  if (!context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin privileges required');
  }

  const { userId, amount, operation } = data as {
    userId: string;
    amount: number;
    operation: string; // 'reset' | 'credit'
  };

  const userRef = db.collection('users').doc(userId);

  await db.runTransaction(async (t) => {
    const snap = await t.get(userRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    let newBalance = 0;
    if (operation === 'reset') {
      newBalance = 0;
    } else if (operation === 'credit') {
      const current = snap.get('coins') || 0;
      newBalance = current + (amount || 0);
    } else {
      throw new functions.https.HttpsError('invalid-argument', 'Unknown operation');
    }
    t.update(userRef, { coins: newBalance });
  });

  return { success: true };
});

