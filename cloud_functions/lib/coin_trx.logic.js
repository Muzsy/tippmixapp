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
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
/**
 * Automatically create a user document when a new Auth user is created.
 */
exports.onUserCreate = functions
    .region('europe-central2')
    .auth.user()
    .onCreate(async (user) => {
    const userRef = firebase_1.db.collection('users').doc(user.uid);
    await userRef.set({
        coins: 50,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    });
});
/**
 * HTTPS Callable function to handle coin transactions atomically.
 * Uses the authenticated user's UID rather than trusting a client-provided ID.
 */
exports.coin_trx = functions
    .region('europe-central2')
    .https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be signed in to perform coin transactions.');
    }
    const userId = context.auth.uid;
    // Unpack and validate parameters
    const { amount, type, reason, transactionId } = data;
    if (typeof amount !== 'number' || amount <= 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Amount must be a positive number.');
    }
    if (type !== 'debit' && type !== 'credit') {
        throw new functions.https.HttpsError('invalid-argument', 'Transaction type must be "debit" or "credit".');
    }
    if (!transactionId) {
        throw new functions.https.HttpsError('invalid-argument', 'A valid transactionId is required.');
    }
    // Prevent duplicate transactions
    const logRef = firebase_1.db.collection('coin_logs').doc(transactionId);
    const existingLog = await logRef.get();
    if (existingLog.exists) {
        return { success: true };
    }
    // Transaction: update user balance and log atomically
    await firebase_1.db.runTransaction(async (tx) => {
        const userRef = firebase_1.db.collection('users').doc(userId);
        const userSnap = await tx.get(userRef);
        // If somehow user doc is missing, initialize with zero balance
        let currentBalance = 0;
        if (!userSnap.exists) {
            tx.set(userRef, { coins: 0, createdAt: firestore_1.FieldValue.serverTimestamp() });
        }
        else {
            currentBalance = userSnap.get('coins') || 0;
        }
        const newBalance = type === 'debit' ? currentBalance - amount : currentBalance + amount;
        if (newBalance < 0) {
            throw new functions.https.HttpsError('failed-precondition', 'Insufficient funds.');
        }
        tx.update(userRef, { coins: newBalance });
        tx.set(logRef, {
            userId,
            amount,
            type,
            reason,
            transactionId,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        });
    });
    return { success: true };
});
