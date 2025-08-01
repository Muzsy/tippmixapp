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
exports.admin_coin_ops = void 0;
const functions = __importStar(require("firebase-functions"));
const firebase_1 = require("./src/lib/firebase");
exports.admin_coin_ops = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }
    if (!context.auth.token.admin) {
        throw new functions.https.HttpsError('permission-denied', 'Admin privileges required');
    }
    const { userId, amount, operation } = data;
    const userRef = firebase_1.db.collection('users').doc(userId);
    await firebase_1.db.runTransaction(async (t) => {
        const snap = await t.get(userRef);
        if (!snap.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }
        let newBalance = 0;
        if (operation === 'reset') {
            newBalance = 0;
        }
        else if (operation === 'credit') {
            const current = snap.get('coins') || 0;
            newBalance = current + (amount || 0);
        }
        else {
            throw new functions.https.HttpsError('invalid-argument', 'Unknown operation');
        }
        t.update(userRef, { coins: newBalance });
    });
    return { success: true };
});
