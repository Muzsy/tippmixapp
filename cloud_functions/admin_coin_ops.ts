import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { db } from './src/lib/firebase';
import { CoinService } from './src/services/CoinService';

export const admin_coin_ops = onCall(async (request) => {
  const data = request.data as any;
  const context = request as any;
  if (!context.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required');
  }

  if (!context.auth.token?.admin) {
    throw new HttpsError('permission-denied', 'Admin privileges required');
  }

  const { userId, amount, operation } = data as {
    userId: string;
    amount: number;
    operation: string; // 'reset' | 'credit'
  };

  const svc = new CoinService();
  if (operation === 'reset') {
    const walletSnap = await db.doc(`users/${userId}/wallet`).get();
    const current = (walletSnap.get('coins') as number) || 0;
    if (current > 0) {
      await svc.debit(userId, current, `admin:reset:${Date.now()}`);
    } else if (current < 0) {
      await svc.credit(userId, Math.abs(current), `admin:reset:${Date.now()}`);
    }
  } else if (operation === 'credit') {
    if (typeof amount !== 'number' || amount <= 0) {
      throw new HttpsError('invalid-argument', 'amount must be positive');
    }
    await svc.credit(userId, amount, `admin:credit:${Date.now()}`);
  } else {
    throw new HttpsError('invalid-argument', 'Unknown operation');
  }
  return { success: true };
});

