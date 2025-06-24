import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

interface CoinTrxData {
  userId: string;
  amount: number;
  type: 'debit' | 'credit';
  reason: string;
  transactionId: string;
}

/**
 * Firestore-triggered function: runs on creation of a ticket document
 * Moves coin logic from HTTPS callable to Firestore onCreate trigger
 */
export const coin_trx = functions
  .region('europe-central2')
  .firestore
  .document('tickets/{ticketId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() as CoinTrxData;
    const { userId, amount, type, reason, transactionId } = data;

    // Validate required fields
    if (!userId || !transactionId || typeof amount !== 'number') {
      throw new Error('Missing or invalid parameters');
    }
    if (type !== 'debit' && type !== 'credit') {
      throw new Error('Invalid transaction type');
    }
    if (amount <= 0) {
      throw new Error('Amount must be positive');
    }

    // Prevent duplicate processing
    const logRef = db.collection('coin_logs').doc(transactionId);
    const existingLog = await logRef.get();
    if (existingLog.exists) {
      // Already processed, nothing to do
      return null;
    }

    // Optional: enforce known reasons and amounts
    const validReasons: Record<string, number> = {
      daily_bonus: 50,
      registration_bonus: 100,
    };
    if (reason in validReasons && validReasons[reason] !== amount) {
      throw new Error('Amount mismatch for reason');
    }

    // Transactionally update user balance and log
    await db.runTransaction(async (tx) => {
      const userRef = db.collection('users').doc(userId);
      const userSnap = await tx.get(userRef);
      if (!userSnap.exists) {
        throw new Error('User not found');
      }

      const currentBalance = (userSnap.get('coins') as number) || 0;
      const newBalance = type === 'debit'
        ? currentBalance - amount
        : currentBalance + amount;

      tx.update(userRef, { coins: newBalance });
      tx.set(logRef, {
        userId,
        amount,
        type,
        reason,
        transactionId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return null;
  });
