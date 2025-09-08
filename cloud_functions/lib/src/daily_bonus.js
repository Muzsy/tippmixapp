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
require("../global");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("./lib/firebase");
const CoinService_1 = require("./services/CoinService");
exports.daily_bonus = (0, scheduler_1.onSchedule)({ schedule: '5 0 * * *', timeZone: 'Europe/Budapest' }, async () => {
    const PAGE = 200;
    const bonusCoins = 50;
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const refId = `daily_bonus_${today}`;
    let lastDoc;
    let total = 0;
    while (true) {
        const q = lastDoc
            ? firebase_1.db.collection('users').orderBy('__name__').startAfter(lastDoc.id).limit(PAGE)
            : firebase_1.db.collection('users').orderBy('__name__').limit(PAGE);
        const snap = await q.get();
        if (snap.empty)
            break;
        for (const doc of snap.docs) {
            const uid = doc.id;
            try {
                await new CoinService_1.CoinService().credit(uid, bonusCoins, refId, 'daily_bonus');
                total++;
            }
            catch (e) {
                logger.error('daily_bonus.credit_failed', { uid, refId, error: e?.message || String(e) });
            }
        }
        lastDoc = snap.docs[snap.docs.length - 1];
        // reduced log volume: page_done log removed
    }
    logger.info('daily_bonus.completed', { total });
});
