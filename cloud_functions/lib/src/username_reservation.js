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
exports.reserve_nickname = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("./lib/firebase");
const normalize_1 = require("./utils/normalize");
exports.reserve_nickname = (0, https_1.onCall)(async (request) => {
    const ctx = request;
    if (!ctx.auth || !ctx.auth.uid)
        throw new https_1.HttpsError('unauthenticated', 'Login required');
    const uid = ctx.auth.uid;
    const { nickname } = (request.data || {});
    if (typeof nickname !== 'string' || !nickname.trim()) {
        throw new https_1.HttpsError('invalid-argument', 'nickname is required');
    }
    if (nickname.length < 3 || nickname.length > 20) {
        throw new https_1.HttpsError('invalid-argument', 'nickname length invalid');
    }
    const norm = (0, normalize_1.normalizeNickname)(nickname);
    const userRef = firebase_1.db.collection('users').doc(uid);
    const resRef = firebase_1.db.collection('usernames').doc(norm);
    try {
        await firebase_1.db.runTransaction(async (tx) => {
            const [resSnap, userSnap] = await Promise.all([tx.get(resRef), tx.get(userRef)]);
            const currentNorm = userSnap.data()?.nicknameNormalized || undefined;
            if (resSnap.exists && resSnap.get('ownerUid') !== uid) {
                throw new https_1.HttpsError('already-exists', 'nickname taken');
            }
            // Create/merge reservation
            tx.set(resRef, { ownerUid: uid, createdAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
            // Update user fields
            tx.set(userRef, { nickname, nicknameNormalized: norm, updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
            // If user had a different reservation, release it
            if (currentNorm && currentNorm !== norm) {
                const oldRef = firebase_1.db.collection('usernames').doc(currentNorm);
                tx.delete(oldRef);
            }
        });
        logger.debug('reserve_nickname.ok', { uid, nickname, norm });
        return { success: true, norm };
    }
    catch (e) {
        if (e instanceof https_1.HttpsError)
            throw e;
        logger.error('reserve_nickname.error', { uid, nickname, error: e?.message || String(e) });
        throw new https_1.HttpsError('internal', 'reservation failed');
    }
});
