"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.admin_coin_ops = void 0;
const https_1 = require("firebase-functions/v2/https");
const firebase_1 = require("./src/lib/firebase");
const CoinService_1 = require("./src/services/CoinService");
exports.admin_coin_ops = (0, https_1.onCall)(async (request) => {
    const data = request.data;
    const context = request;
    if (!context.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    if (!context.auth.token?.admin) {
        throw new https_1.HttpsError('permission-denied', 'Admin privileges required');
    }
    const { userId, amount, operation } = data;
    const svc = new CoinService_1.CoinService();
    if (operation === 'reset') {
        const walletSnap = await firebase_1.db.doc(`users/${userId}/wallet`).get();
        const current = walletSnap.get('coins') || 0;
        if (current > 0) {
            await svc.debit(userId, current, `admin:reset:${Date.now()}`);
        }
        else if (current < 0) {
            await svc.credit(userId, Math.abs(current), `admin:reset:${Date.now()}`);
        }
    }
    else if (operation === 'credit') {
        if (typeof amount !== 'number' || amount <= 0) {
            throw new https_1.HttpsError('invalid-argument', 'amount must be positive');
        }
        await svc.credit(userId, amount, `admin:credit:${Date.now()}`);
    }
    else {
        throw new https_1.HttpsError('invalid-argument', 'Unknown operation');
    }
    return { success: true };
});
