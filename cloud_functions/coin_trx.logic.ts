import * as functions from 'firebase-functions';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

/**
 * Automatically create a user document when a new Auth user is created.
 */
export const onUserCreate = functions
  .region('europe-central2')
  .auth.user()
  .onCreate(async (user) => {
    const userRef = db.collection('users').doc(user.uid);
    await userRef.set({
      coins: 50,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

interface CoinTrxData {
  amount: number;
  type: 'debit' | 'credit';
  reason: string;
  transactionId: string;
}

/**
 * HTTPS Callable function to handle coin transactions atomically.
 * Uses the authenticated user's UID rather than trusting a client-provided ID.
 */
export const coin_trx = functions
  .region('europe-central2')
  .https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth || !context.auth.uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be signed in to perform coin transactions.'
      );
    }
    const userId = context.auth.uid;

    // Unpack and validate parameters
    const { amount, type, reason, transactionId } = data as CoinTrxData;
    if (typeof amount !== 'number' || amount <= 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Amount must be a positive number.'
      );
    }
    if (type !== 'debit' && type !== 'credit') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Transaction type must be "debit" or "credit".'
      );
    }
    if (!transactionId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'A valid transactionId is required.'
      );
    }

    // Prevent duplicate transactions
    const logRef = db.collection('coin_logs').doc(transactionId);
    const existingLog = await logRef.get();
    if (existingLog.exists) {
      return { success: true };
    }

    // Transaction: update user balance and log atomically
    await db.runTransaction(async (tx) => {
      const userRef = db.collection('users').doc(userId);
      const userSnap = await tx.get(userRef);

      // If somehow user doc is missing, initialize with zero balance
      let currentBalance = 0;
      if (!userSnap.exists) {
        tx.set(userRef, { coins: 0, createdAt: FieldValue.serverTimestamp() });
      } else {
        currentBalance = (userSnap.get('coins') as number) || 0;
      }

      const newBalance = type === 'debit' ? currentBalance - amount : currentBalance + amount;
      if (newBalance < 0) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Insufficient funds.'
        );
      }

      tx.update(userRef, { coins: newBalance });
      tx.set(logRef, {
        userId,
        amount,
        type,
        reason,
        transactionId,
        timestamp: FieldValue.serverTimestamp(),
      });
    });

    return { success: true };
  });
