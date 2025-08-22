"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.daily_bonus = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firebase_1 = require("./lib/firebase");
const CoinService_1 = require("./services/CoinService");
exports.daily_bonus = (0, scheduler_1.onSchedule)({ schedule: '5 0 * * *', timeZone: 'Europe/Budapest' }, async () => {
    const usersSnap = await firebase_1.db.collection('users').get();
    const bonusCoins = 50;
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const refId = `daily_bonus_${today}`;
    for (const doc of usersSnap.docs) {
        const uid = doc.id;
        await new CoinService_1.CoinService().credit(uid, bonusCoins, refId);
    }
});
