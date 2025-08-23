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
require("./global");
const https_1 = require("firebase-functions/v2/https");
const functions = __importStar(require("firebase-functions/v1"));
const firestore_1 = require("firebase-admin/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("./src/lib/firebase");
const CoinService_1 = require("./src/services/CoinService");
/**
 * Automatically create a user document when a new Auth user is created.
 * Note: the v2 identity module lacks an onUserCreated handler; use the v1 Auth trigger alongside v2 functions.
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
    const userRef = firebase_1.db.collection('users').doc(user.uid);
    await userRef.set({ createdAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
    const walletRef = firebase_1.db.doc(`users/${user.uid}/wallet`);
    await walletRef.set({ coins: 50, updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
    // Bonus Engine – optional signup bonus
    const rulesSnap = await firebase_1.db.doc('system_configs/bonus_rules').get();
    if (rulesSnap.exists) {
        const rules = rulesSnap.data();
        const signup = rules?.signup;
        if (signup?.enabled === true) {
            const bonusStateRef = firebase_1.db.doc(`users/${user.uid}/bonus_state`);
            await firebase_1.db.runTransaction(async (t) => {
                const st = await t.get(bonusStateRef);
                const already = st.exists && st.get('signupClaimed') === true;
                if (signup.once === true && already)
                    return;
                const beforeSnap = await t.get(walletRef);
                const before = beforeSnap.get('coins') ?? 0;
                const svc = new CoinService_1.CoinService();
                await svc.credit(user.uid, Number(signup.amount || 0), 'bonus:signup', 'signup_bonus', t, before);
                t.set(bonusStateRef, { signupClaimed: true, lastAppliedVersion: rules.version ?? 1 }, { merge: true });
            });
        }
    }
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
    try {
        let after = 0;
        // Transaction: wallet + ledger (SoT)
        await firebase_1.db.runTransaction(async (tx) => {
            const userRef = firebase_1.db.collection('users').doc(userId);
            const walletRef = firebase_1.db.doc(`users/${userId}/wallet`);
            const walletSnap = await tx.get(walletRef);
            const before = walletSnap.data()?.coins ?? 0;
            const delta = type === 'debit' ? -Math.abs(amount) : Math.abs(amount);
            after = before + delta;
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
        logger.info('coin_trx.success', { uid: userId, type, amount, transactionId, after });
        return { success: true, balance: after };
    }
    catch (e) {
        logger.error('coin_trx.error', { uid: context?.auth?.uid, type, amount, transactionId, error: e?.message || String(e) });
        throw new https_1.HttpsError('internal', e?.message || 'Unknown error');
    }
});
