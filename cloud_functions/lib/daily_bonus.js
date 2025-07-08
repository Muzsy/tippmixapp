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
exports.daily_bonus = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
exports.daily_bonus = functions
    .region('europe-central2')
    .pubsub.schedule('5 0 * * *')
    .timeZone('Europe/Budapest')
    .onRun(async () => {
    const usersSnap = await firebase_1.db.collection('users').get();
    const batch = firebase_1.db.batch();
    usersSnap.docs.forEach((doc) => {
        const userId = doc.id;
        const logRef = firebase_1.db
            .collection('users')
            .doc(userId)
            .collection('coin_logs')
            .doc();
        batch.set(logRef, {
            userId,
            amount: 50,
            type: 'credit',
            reason: 'daily_bonus',
            transactionId: logRef.id,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
            description: 'Daily bonus',
        });
    });
    await batch.commit();
});
