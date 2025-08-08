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
exports.match_finalizer = void 0;
const admin = __importStar(require("firebase-admin"));
const ResultProvider_1 = require("./services/ResultProvider");
const CoinService_1 = require("./services/CoinService");
admin.initializeApp();
const db = admin.firestore();
const resultProvider = new ResultProvider_1.ResultProvider();
const coinService = new CoinService_1.CoinService();
const match_finalizer = async (message) => {
    const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
    const { job } = JSON.parse(payloadStr);
    console.log(`[match_finalizer] received job: ${job}`);
    // 1) Collect pending tickets + related eventIds
    const ticketsSnap = await db.collection('tickets')
        .where('status', '==', 'pending')
        .get();
    if (ticketsSnap.empty) {
        console.log('[match_finalizer] no pending tickets – exit');
        return;
    }
    const eventIdSet = new Set();
    ticketsSnap.docs.forEach(doc => {
        eventIdSet.add(doc.get('eventId'));
    });
    const eventIds = Array.from(eventIdSet);
    console.log(`[match_finalizer] found ${eventIds.length} unique eventIds`);
    // 2) Fetch scores
    let scores;
    try {
        scores = await resultProvider.getScores(eventIds);
    }
    catch (err) {
        console.error('[match_finalizer] ResultProvider error', err);
        throw err; // message will be retried / DLQ
    }
    // 3) Map of completed results
    const completedMap = new Map();
    scores.filter(s => s.completed).forEach(s => completedMap.set(s.id, (s.scores?.home || 0) > (s.scores?.away || 0)));
    // 4) Iterate over tickets and update if completed
    const batch = db.batch();
    ticketsSnap.docs.forEach(doc => {
        const eventId = doc.get('eventId');
        if (completedMap.has(eventId)) {
            const won = completedMap.get(eventId);
            batch.update(doc.ref, {
                status: won ? 'won' : 'lost'
            });
            if (won) {
                coinService.credit(doc.get('uid'), doc.get('potentialProfit'), doc.id);
            }
        }
    });
    await batch.commit();
    console.log('[match_finalizer] batch commit done');
};
exports.match_finalizer = match_finalizer;
