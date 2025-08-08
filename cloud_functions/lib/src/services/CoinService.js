"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.CoinService = void 0;
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
class CoinService {
    /**
     * Idempotens TIPP‑Coin jóváírás.
     * @param uid felhasználó azonosító
     * @param amount pozitív (nyeremény) vagy negatív (tétlevonás) összeg
     * @param ticketId az érintett szelvény azonosítója – ledger primary key
     */
    async transact(uid, amount, ticketId, type) {
        const walletRef = db.doc(`wallets/${uid}`);
        const ledgerRef = walletRef.collection('ledger').doc(ticketId);
        await db.runTransaction(async (tx) => {
            const ledgerSnap = await tx.get(ledgerRef);
            if (ledgerSnap.exists) {
                // Idempotens: már jóváírva
                return;
            }
            // Balance frissítés (wallet doksi létrehozása, ha hiányzik)
            tx.set(walletRef, {
                balance: admin.firestore.FieldValue.increment(amount),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });
            // Ledger entry
            tx.set(ledgerRef, {
                amount,
                type,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
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
