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
    await userRef.set({ createdAt: FieldValue.serverTimestamp() }, { merge: true });
    const walletRef = db.doc(`users/${user.uid}/wallet`);
    await walletRef.set({ coins: 50, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
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

    // Idempotencia: ledger primer kulcs a transactionId lesz
    const ledgerRef = db.doc(`users/${userId}/ledger/${transactionId}`);
    const existingLedger = await ledgerRef.get();
    if (existingLedger.exists) {
      return { success: true };
    }

    // Transaction: wallet + ledger (SoT)
    await db.runTransaction(async (tx) => {
      const userRef = db.collection('users').doc(userId);
      const walletRef = db.doc(`users/${userId}/wallet`);
      const walletSnap = await tx.get(walletRef);
      const before = (walletSnap.data()?.coins as number) ?? 0;
      const delta = type === 'debit' ? -Math.abs(amount) : Math.abs(amount);
      const after = before + delta;

      tx.set(walletRef, { coins: FieldValue.increment(delta), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      tx.set(ledgerRef, {
        type: type === 'debit' ? 'bet' : 'bonus',
        amount: delta,
        before,
        after,
        refId: transactionId,
        source: 'coin_trx',
        createdAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    return { success: true };
  });
