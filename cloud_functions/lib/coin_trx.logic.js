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
/**
 * Firestore-triggered function: runs on creation of a ticket document
 * Moves coin logic from HTTPS callable to Firestore onCreate trigger
 */
exports.coin_trx = functions
    .region('europe-central2')
    .firestore
    .document('tickets/{ticketId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    const { userId, amount, type, reason, transactionId } = data;
    // Validate required fields
    if (!userId || !transactionId || typeof amount !== 'number') {
        throw new Error('Missing or invalid parameters');
    }
    if (type !== 'debit' && type !== 'credit') {
        throw new Error('Invalid transaction type');
    }
    if (amount <= 0) {
        throw new Error('Amount must be positive');
    }
    // Prevent duplicate processing
    const logRef = db.collection('coin_logs').doc(transactionId);
    const existingLog = await logRef.get();
    if (existingLog.exists) {
        // Already processed, nothing to do
        return null;
    }
    // Optional: enforce known reasons and amounts
    const validReasons = {
        daily_bonus: 50,
        registration_bonus: 100,
    };
    if (reason in validReasons && validReasons[reason] !== amount) {
        throw new Error('Amount mismatch for reason');
    }
    // Transactionally update user balance and log
    await db.runTransaction(async (tx) => {
        const userRef = db.collection('users').doc(userId);
        const userSnap = await tx.get(userRef);
        if (!userSnap.exists) {
            throw new Error('User not found');
        }
        const currentBalance = userSnap.get('coins') || 0;
        const newBalance = type === 'debit'
            ? currentBalance - amount
            : currentBalance + amount;
        tx.update(userRef, { coins: newBalance });
        tx.set(logRef, {
            userId,
            amount,
            type,
            reason,
            transactionId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
    });
    return null;
});
