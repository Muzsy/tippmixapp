import { db } from '../lib/firebase';
import { FieldValue } from 'firebase-admin/firestore';

export class CoinService {
  /**
   * Idempotens TIPP‑Coin jóváírás.
   * @param uid felhasználó azonosító
   * @param amount pozitív (nyeremény) vagy negatív (tétlevonás) összeg
   * @param ticketId az érintett szelvény azonosítója – ledger primary key
   */
  async transact(uid: string, amount: number, ticketId: string, type: 'win' | 'bet'): Promise<void> {
    const walletRef = db.doc(`wallets/${uid}`);
    const ledgerRef = walletRef.collection('ledger').doc(ticketId);
    // NEW (dual write): user-centric SoT
    const newWalletRef = db.doc(`users/${uid}/wallet`);
    const newLedgerRef = db.doc(`users/${uid}/ledger/${ticketId}`);

    await db.runTransaction(async (tx) => {
      const ledgerSnap = await tx.get(ledgerRef);
      if (ledgerSnap.exists) {
        // Idempotens: már jóváírva
        return;
      }

      // Balance frissítés (wallet doksi létrehozása, ha hiányzik)
      tx.set(walletRef, {
        balance: FieldValue.increment(amount),
        updatedAt: FieldValue.serverTimestamp()
      }, { merge: true });

      // Ledger entry
      tx.set(ledgerRef, {
        amount,
        type,
        createdAt: FieldValue.serverTimestamp()
      });
    });
  }

  /** Convenience wrap – nyeremény jóváírás */
  credit(uid: string, amount: number, ticketId: string) {
    return this.transact(uid, amount, ticketId, 'win');
  }

  /** Convenience wrap – tét levonás */
  debit(uid: string, amount: number, ticketId: string) {
    return this.transact(uid, -Math.abs(amount), ticketId, 'bet');
  }
}
