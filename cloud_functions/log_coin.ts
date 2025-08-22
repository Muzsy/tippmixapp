import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

interface LogData {
  amount: number;
  type: string;
  meta?: Record<string, unknown>;
  transactionId: string;
}

export const log_coin = onCall(async (request) => {
  const data = request.data as LogData;
  const context = request as any;
  if (!context.auth || !context.auth.uid) {
    throw new HttpsError('unauthenticated', 'Must be signed in');
  }
  if (!context.auth.token?.admin) {
    throw new HttpsError('permission-denied', 'Admin only');
  }
  const { amount, type, meta, transactionId } = data;

  if (typeof amount !== 'number' || amount === 0) {
    throw new HttpsError('invalid-argument', 'Amount must be a non-zero number');
  }
  const allowed = ['bet', 'deposit', 'withdraw', 'adjust'];
  if (!allowed.includes(type)) {
    throw new HttpsError('invalid-argument', 'Invalid log type');
  }
  if (!transactionId) {
    throw new HttpsError('invalid-argument', 'transactionId required');
  }

  const logRef = db.doc(`system_counters/coin_logs_legacy/logs/${transactionId}`);
  await logRef.set(
    {
      amount,
      type,
      refId: transactionId,
      source: 'log_coin',
      meta,
      createdAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  return { success: true };
});
