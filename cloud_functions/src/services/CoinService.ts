import * as admin from 'firebase-admin';
const db = admin.firestore();

export class CoinService {
  /**
   * Credits a user wallet – stub implementation. Will be refined in coin-credit-task.
   */
  async credit(uid: string, amount: number): Promise<void> {
    console.log(`[CoinService] credit ${amount} coins to ${uid}`);
    // TODO: implement transactional wallet update.
    await db.doc(`wallets/${uid}`).set({
      balance: admin.firestore.FieldValue.increment(amount)
    }, { merge: true });
  }
}

