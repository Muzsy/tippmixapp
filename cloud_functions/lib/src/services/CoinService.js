"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CoinService = void 0;
const firebase_1 = require("../lib/firebase");
const firestore_1 = require("firebase-admin/firestore");
class CoinService {
    /**
     * Idempotens TIPP‑Coin jóváírás.
     * @param uid felhasználó azonosító
     * @param amount pozitív (nyeremény) vagy negatív (tétlevonás) összeg
     * @param ticketId az érintett szelvény azonosítója – ledger primary key
     */
    async transact(uid, amount, ticketId, type) {
        const walletRef = firebase_1.db.doc(`users/${uid}/wallet`);
        const ledgerRef = firebase_1.db.doc(`users/${uid}/ledger/${ticketId}`);
        await firebase_1.db.runTransaction(async (tx) => {
            const ledgerSnap = await tx.get(ledgerRef);
            if (ledgerSnap.exists) {
                // Idempotens: már jóváírva
                return;
            }
            // Balance frissítés (wallet doksi létrehozása, ha hiányzik)
            tx.set(walletRef, {
                coins: firestore_1.FieldValue.increment(amount),
                updatedAt: firestore_1.FieldValue.serverTimestamp(),
            }, { merge: true });
            // Ledger entry az új SoT alatt
            tx.set(ledgerRef, {
                userId: uid,
                amount,
                type,
                refId: ticketId,
                source: 'coin_trx',
                createdAt: firestore_1.FieldValue.serverTimestamp(),
            }, { merge: true });
        });
    }
    /** Convenience wrap – nyeremény jóváírás */
    credit(uid, amount, ticketId) {
        return this.transact(uid, amount, ticketId, 'win');
    }
    /** Convenience wrap – tét levonás */
    debit(uid, amount, ticketId) {
        return this.transact(uid, -Math.abs(amount), ticketId, 'bet');
    }
}
exports.CoinService = CoinService;
