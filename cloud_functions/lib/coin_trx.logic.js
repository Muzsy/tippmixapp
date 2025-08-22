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
exports.coin_trx = exports.onUserCreate = void 0;
const https_1 = require("firebase-functions/v2/https");
const identity = __importStar(require("firebase-functions/v2/identity"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
/**
 * Automatically create a user document when a new Auth user is created.
 */
exports.onUserCreate = identity.onUserCreated(async (event) => {
    const user = event.data;
    const userRef = firebase_1.db.collection('users').doc(user.uid);
    await userRef.set({ createdAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
    const walletRef = firebase_1.db.doc(`users/${user.uid}/wallet`);
    await walletRef.set({ coins: 50, updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
});
/**
 * HTTPS Callable function to handle coin transactions atomically.
 * Uses the authenticated user's UID rather than trusting a client-provided ID.
 */
exports.coin_trx = (0, https_1.onCall)(async (request) => {
    const data = request.data;
    const context = request;
    // Ensure the user is authenticated
    if (!context.auth || !context.auth.uid) {
        throw new https_1.HttpsError('unauthenticated', 'User must be signed in to perform coin transactions.');
    }
    const userId = context.auth.uid;
    // Unpack and validate parameters
    const { amount, type, reason, transactionId } = data;
    if (typeof amount !== 'number' || amount <= 0) {
        throw new https_1.HttpsError('invalid-argument', 'Amount must be a positive number.');
    }
    if (type !== 'debit' && type !== 'credit') {
        throw new https_1.HttpsError('invalid-argument', 'Transaction type must be "debit" or "credit".');
    }
    if (!transactionId) {
        throw new https_1.HttpsError('invalid-argument', 'A valid transactionId is required.');
    }
    // Idempotencia: ledger primer kulcs a transactionId lesz
    const ledgerRef = firebase_1.db.doc(`users/${userId}/ledger/${transactionId}`);
    const existingLedger = await ledgerRef.get();
    if (existingLedger.exists) {
        return { success: true };
    }
    // Transaction: wallet + ledger (SoT)
    await firebase_1.db.runTransaction(async (tx) => {
        const userRef = firebase_1.db.collection('users').doc(userId);
        const walletRef = firebase_1.db.doc(`users/${userId}/wallet`);
        const walletSnap = await tx.get(walletRef);
        const before = walletSnap.data()?.coins ?? 0;
        const delta = type === 'debit' ? -Math.abs(amount) : Math.abs(amount);
        const after = before + delta;
        tx.set(walletRef, { coins: firestore_1.FieldValue.increment(delta), updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
        tx.set(ledgerRef, {
            type: type === 'debit' ? 'bet' : 'bonus',
            amount: delta,
            before,
            after,
            refId: transactionId,
            source: 'coin_trx',
            createdAt: firestore_1.FieldValue.serverTimestamp(),
        }, { merge: true });
    });
    return { success: true };
});
