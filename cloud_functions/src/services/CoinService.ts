import { createHash } from 'crypto';
import { db } from '../lib/firebase';
import { FieldValue, Transaction } from 'firebase-admin/firestore';

export class CoinService {
  private async writeLedger(
    t: Transaction,
    uid: string,
    type: 'bet' | 'win' | 'bonus' | 'refund' | 'adjust',
    amount: number,
    before: number,
    after: number,
    refId: string,
    source: string,
  ) {
    const ledgerRef = db.collection('users').doc(uid).collection('ledger').doc(refId);
    const checksum = createHash('sha1')
      .update(`${uid}:${type}:${refId}:${amount}`)
      .digest('hex');
    t.set(
      ledgerRef,
      { type, amount, before, after, refId, source, checksum, createdAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
  }

  private async transact(
    uid: string,
    amount: number,
    refId: string,
    type: 'bet' | 'win' | 'bonus' | 'refund' | 'adjust',
    source: string,
    t?: Transaction,
    before?: number,
  ) {
    const walletRef = db.doc(`users/${uid}/wallet`);
    if (t) {
      const ledgerRef = db.collection('users').doc(uid).collection('ledger').doc(refId);
      // Idempotency: skip if ledger entry already exists
      const existing = await t.get(ledgerRef);
      if (existing.exists) {
        return; // idempotent no-op
      }
      const beforeBal = before ?? ((await t.get(walletRef)).data()?.coins as number) ?? 0;
      const after = beforeBal + amount;
      t.set(
        walletRef,
        { coins: FieldValue.increment(amount), updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      await this.writeLedger(t, uid, type, amount, beforeBal, after, refId, source);
      return;
    }

    await db.runTransaction(async (tx) => {
      const ledgerRef = db.collection('users').doc(uid).collection('ledger').doc(refId);
      const existing = await tx.get(ledgerRef);
      if (existing.exists) {
        return; // idempotent no-op
      }
      const snap = await tx.get(walletRef);
      const beforeBal = (snap.data()?.coins as number) ?? 0;
      const after = beforeBal + amount;
      tx.set(
        walletRef,
        { coins: FieldValue.increment(amount), updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      await this.writeLedger(tx, uid, type, amount, beforeBal, after, refId, source);
    });
  }

  credit(
    uid: string,
    amount: number,
    refId: string,
    source = 'coin_trx',
    t?: Transaction,
    before?: number,
  ) {
    const type = source === 'coin_trx' ? 'win' : 'bonus';
    return this.transact(uid, Math.abs(amount), refId, type, source, t, before);
  }

  debit(
    uid: string,
    amount: number,
    refId: string,
    source = 'coin_trx',
    t?: Transaction,
    before?: number,
  ) {
    const type = source === 'coin_trx' ? 'bet' : 'adjust';
    return this.transact(uid, -Math.abs(amount), refId, type, source, t, before);
  }
}
