"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.log_coin = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
exports.log_coin = functions
  .region('europe-central2')
  .https.onCall(async (data, context) => {
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }
    const { amount, type, meta, transactionId } = data;
    if (typeof amount !== 'number' || amount === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Amount must be a non-zero number');
    }
    const allowed = ['bet', 'deposit', 'withdraw', 'adjust'];
    if (!allowed.includes(type)) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid log type');
    }
    if (!transactionId) {
        throw new functions.https.HttpsError('invalid-argument', 'transactionId required');
    }
    const logRef = db.collection('coin_logs').doc(transactionId);
    await logRef.set({
        userId: context.auth.uid,
        amount,
        type,
        meta,
        transactionId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
});
