"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.log_coin = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
exports.log_coin = (0, https_1.onCall)(async (request) => {
    const data = request.data;
    const context = request;
    if (!context.auth || !context.auth.uid) {
        throw new https_1.HttpsError('unauthenticated', 'Must be signed in');
    }
    if (!context.auth.token?.admin) {
        throw new https_1.HttpsError('permission-denied', 'Admin only');
    }
    const { amount, type, meta, transactionId } = data;
    if (typeof amount !== 'number' || amount === 0) {
        throw new https_1.HttpsError('invalid-argument', 'Amount must be a non-zero number');
    }
    const allowed = ['bet', 'deposit', 'withdraw', 'adjust'];
    if (!allowed.includes(type)) {
        throw new https_1.HttpsError('invalid-argument', 'Invalid log type');
    }
    if (!transactionId) {
        throw new https_1.HttpsError('invalid-argument', 'transactionId required');
    }
    const logRef = firebase_1.db.doc(`system_counters/coin_logs_legacy/logs/${transactionId}`);
    await logRef.set({
        amount,
        type,
        refId: transactionId,
        source: 'log_coin',
        meta,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    }, { merge: true });
    return { success: true };
});
