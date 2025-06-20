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
exports.coin_trx = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
exports.coin_trx = functions
    .region('europe-central2') // <<< EZT TETTÜK HOZZÁ
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }
    const { userId, amount, type, reason, transactionId } = data;
    if (!userId || !transactionId || typeof amount !== 'number') {
        throw new functions.https.HttpsError('invalid-argument', 'Missing parameters');
    }
    if (type !== 'debit' && type !== 'credit') {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type');
    }
    if (amount <= 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
    }
    const logRef = db.collection('coin_logs').doc(transactionId);
    const existing = await logRef.get();
    if (existing.exists) {
        throw new functions.https.HttpsError('already-exists', 'Transaction already processed');
    }
    const validReasons = {
        daily_bonus: 50,
        registration_bonus: 100,
    };
    if (reason in validReasons && validReasons[reason] !== amount) {
        throw new functions.https.HttpsError('invalid-argument', 'Amount mismatch for reason');
    }
    await db.runTransaction(async (t) => {
        const userRef = db.collection('users').doc(userId);
        const snap = await t.get(userRef);
        if (!snap.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }
        const current = snap.get('coins') || 0;
        const newBalance = type === 'debit' ? current - amount : current + amount;
        t.update(userRef, { coins: newBalance });
        t.set(logRef, {
            userId,
            amount,
            type,
            reason,
            transactionId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
    });
    return { success: true };
});
