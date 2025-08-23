"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CoinService = void 0;
const crypto_1 = require("crypto");
const firebase_1 = require("../lib/firebase");
const firestore_1 = require("firebase-admin/firestore");
class CoinService {
    async writeLedger(t, uid, type, amount, before, after, refId, source) {
        const ledgerRef = firebase_1.db.collection('users').doc(uid).collection('ledger').doc(refId);
        const checksum = (0, crypto_1.createHash)('sha1')
            .update(`${uid}:${type}:${refId}:${amount}`)
            .digest('hex');
        t.set(ledgerRef, { type, amount, before, after, refId, source, checksum, createdAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
    }
    async transact(uid, amount, refId, type, source, t, before) {
        const walletRef = firebase_1.db.doc(`users/${uid}/wallet`);
        if (t) {
            const ledgerRef = firebase_1.db.collection('users').doc(uid).collection('ledger').doc(refId);
            // Idempotency: skip if ledger entry already exists
            const existing = await t.get(ledgerRef);
            if (existing.exists) {
                return; // idempotent no-op
            }
            const beforeBal = before ?? (await t.get(walletRef)).data()?.coins ?? 0;
            const after = beforeBal + amount;
            t.set(walletRef, { coins: firestore_1.FieldValue.increment(amount), updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
            await this.writeLedger(t, uid, type, amount, beforeBal, after, refId, source);
            return;
        }
        await firebase_1.db.runTransaction(async (tx) => {
            const ledgerRef = firebase_1.db.collection('users').doc(uid).collection('ledger').doc(refId);
            const existing = await tx.get(ledgerRef);
            if (existing.exists) {
                return; // idempotent no-op
            }
            const snap = await tx.get(walletRef);
            const beforeBal = snap.data()?.coins ?? 0;
            const after = beforeBal + amount;
            tx.set(walletRef, { coins: firestore_1.FieldValue.increment(amount), updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
            await this.writeLedger(tx, uid, type, amount, beforeBal, after, refId, source);
        });
    }
    credit(uid, amount, refId, source = 'coin_trx', t, before) {
        const type = source === 'coin_trx' ? 'win' : 'bonus';
        return this.transact(uid, Math.abs(amount), refId, type, source, t, before);
    }
    debit(uid, amount, refId, source = 'coin_trx', t, before) {
        const type = source === 'coin_trx' ? 'bet' : 'adjust';
        return this.transact(uid, -Math.abs(amount), refId, type, source, t, before);
    }
}
exports.CoinService = CoinService;
