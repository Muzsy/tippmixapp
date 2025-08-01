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
exports.log_coin = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
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
    const logRef = firebase_1.db.collection('coin_logs').doc(transactionId);
    await logRef.set({
        userId: context.auth.uid,
        amount,
        type,
        meta,
        transactionId,
        timestamp: firestore_1.FieldValue.serverTimestamp(),
    });
    return { success: true };
});
