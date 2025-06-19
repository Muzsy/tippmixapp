import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Logic based on docs/tippmix_app_teljes_adatmodell.md and bonus_policy.md

admin.initializeApp();
const db = admin.firestore();

interface CoinTrxData {
  userId: string;
  amount: number;
  type: string; // 'debit' or 'credit'
  reason: string;
  transactionId: string;
}

export const coin_trx = functions.https.onCall(async (data: CoinTrxData, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  const { userId, amount, type, reason, transactionId } = data;

  if (!userId || !transactionId || typeof amount !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing parameters');
  }
  if (type !== 'debit' && type !== 'credit') {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid type');
  }
  if (amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }

  const logRef = db.collection('coin_logs').doc(transactionId);
  const existing = await logRef.get();
  if (existing.exists) {
    throw new functions.https.HttpsError('already-exists', 'Transaction already processed');
  }

  const validReasons: Record<string, number> = {
    daily_bonus: 50,
    registration_bonus: 100,
  };

  if (reason in validReasons && validReasons[reason] !== amount) {
    throw new functions.https.HttpsError('invalid-argument', 'Amount mismatch for reason');
  }

  await db.runTransaction(async (t) => {
    const userRef = db.collection('users').doc(userId);
    const snap = await t.get(userRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    const current = snap.get('coins') || 0;
    const newBalance = type === 'debit' ? current - amount : current + amount;
    t.update(userRef, { coins: newBalance });
    t.set(logRef, {
      userId,
      amount,
      type,
      reason,
      transactionId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { success: true };
});

