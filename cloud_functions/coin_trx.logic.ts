import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as identity from 'firebase-functions/v2/identity';
import { FieldValue } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { db } from './src/lib/firebase';
import { CoinService } from './src/services/CoinService';

/**
 * Automatically create a user document when a new Auth user is created.
 */
export const onUserCreate = (identity as any).onUserCreated(async (event: any) => {
  const user = event.data;
  const userRef = db.collection('users').doc(user.uid);
  await userRef.set({ createdAt: FieldValue.serverTimestamp() }, { merge: true });
  const walletRef = db.doc(`users/${user.uid}/wallet`);
  await walletRef.set({ coins: 50, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
  // Bonus Engine – optional signup bonus
  const rulesSnap = await db.doc('system_configs/bonus_rules').get();
  if (rulesSnap.exists) {
    const rules: any = rulesSnap.data();
    const signup = rules?.signup;
    if (signup?.enabled === true) {
      const bonusStateRef = db.doc(`users/${user.uid}/bonus_state`);
      await db.runTransaction(async (t) => {
        const st = await t.get(bonusStateRef);
        const already = st.exists && st.get('signupClaimed') === true;
        if (signup.once === true && already) return;
        const beforeSnap = await t.get(walletRef);
        const before = (beforeSnap.get('coins') as number) ?? 0;
        const svc = new CoinService();
        await svc.credit(user.uid, Number(signup.amount || 0), 'bonus:signup', 'signup_bonus', t, before);
        t.set(bonusStateRef, { signupClaimed: true, lastAppliedVersion: rules.version ?? 1 }, { merge: true });
      });
    }
  }
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
export const coin_trx = onCall(async (request) => {
  const data = request.data as CoinTrxData;
  const context = request as any;
  // Ensure the user is authenticated
  if (!context.auth || !context.auth.uid) {
    throw new HttpsError(
      'unauthenticated',
      'User must be signed in to perform coin transactions.'
    );
  }
  const userId = context.auth.uid;

  // Unpack and validate parameters
  const { amount, type, reason, transactionId } = data;
  if (typeof amount !== 'number' || amount <= 0) {
    throw new HttpsError(
      'invalid-argument',
      'Amount must be a positive number.'
    );
  }
  if (type !== 'debit' && type !== 'credit') {
    throw new HttpsError(
      'invalid-argument',
      'Transaction type must be "debit" or "credit".'
    );
  }
  if (!transactionId) {
    throw new HttpsError(
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

  try {
    let after = 0;
    // Transaction: wallet + ledger (SoT)
    await db.runTransaction(async (tx) => {
      const userRef = db.collection('users').doc(userId);
      const walletRef = db.doc(`users/${userId}/wallet`);
      const walletSnap = await tx.get(walletRef);
      const before = (walletSnap.data()?.coins as number) ?? 0;
      const delta = type === 'debit' ? -Math.abs(amount) : Math.abs(amount);
      after = before + delta;

      tx.set(walletRef, { coins: FieldValue.increment(delta), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      tx.set(
        ledgerRef,
        {
          type: type === 'debit' ? 'bet' : 'bonus',
          amount: delta,
          before,
          after,
          refId: transactionId,
          source: 'coin_trx',
          createdAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    });
    logger.info('coin_trx.success', { uid: userId, type, amount, transactionId, after });
    return { success: true, balance: after };
  } catch (e: any) {
    logger.error('coin_trx.error', { uid: context?.auth?.uid, type, amount, transactionId, error: e?.message || String(e) });
    throw new HttpsError('internal', e?.message || 'Unknown error');
  }
});
