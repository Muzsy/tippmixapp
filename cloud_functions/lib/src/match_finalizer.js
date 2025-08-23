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
const ApiFootballResultProvider_1 = require("./services/ApiFootballResultProvider");
const payout_1 = require("./tickets/payout");
const firestore_1 = require("firebase-admin/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("./lib/firebase");
const CoinService_1 = require("./services/CoinService");
const evaluators_1 = require("./evaluators");
const provider = new ApiFootballResultProvider_1.ApiFootballResultProvider();
// After computing tip results for a ticket
async function finalizeTicketAtomic(ticketRef, userRef, ticketData) {
    const db = (0, firestore_1.getFirestore)();
    await db.runTransaction(async (tx) => {
        const [tSnap] = await Promise.all([tx.get(ticketRef), tx.get(userRef)]);
        const t = tSnap.data();
        if (!t)
            throw new Error('Ticket not found');
        if (t.processedAt) {
            return; // idempotent exit
        }
        const tips = (ticketData.tips || []).map((x) => ({
            market: x.market,
            selection: x.selection,
            result: x.result,
            oddsSnapshot: x.oddsSnapshot,
        }));
        // If any pending remain, do nothing
        if (tips.some((x) => x.result === 'pending'))
            return;
        const payout = (0, payout_1.calcTicketPayout)(ticketData.stake, tips);
        const status = tips.some((x) => x.result === 'lost') ? 'lost' : (payout > 0 ? 'won' : 'void');
        // users.balance helyett csak a ticket mezői frissülnek; pénzügy a CoinService-ben
        tx.update(ticketRef, { status, payout, processedAt: new Date(), tips });
    });
}
const match_finalizer = async (message) => {
    logger.info('match_finalizer.handle', { hasData: !!message?.data, attrKeys: Object.keys(message.attributes || {}) });
    try {
        const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
        const { job } = JSON.parse(payloadStr);
        // 1) Collect pending tickets across all users via collectionGroup
        // Tickets are stored under /tickets/{uid}/tickets/{ticketId}
        const ticketsSnap = await firebase_1.db
            .collectionGroup('tickets')
            .where('status', '==', 'pending')
            .limit(200)
            .get();
        if (ticketsSnap.empty) {
            logger.info('match_finalizer.no_pending');
            return;
        }
        logger.info('match_finalizer.pending_tickets', { count: ticketsSnap.size });
        // Gather unique eventIds from tips[] arrays
        const eventIdSet = new Set();
        for (const doc of ticketsSnap.docs) {
            const tips = doc.get('tips') || [];
            for (const t of tips) {
                if (t && typeof t.eventId === 'string' && t.eventId.trim()) {
                    eventIdSet.add(t.eventId.trim());
                }
            }
        }
        const eventIds = Array.from(eventIdSet);
        logger.info('match_finalizer.unique_events', { count: eventIds.length });
        // 2) Fetch scores
        let scores;
        try {
            scores = await provider.getScores(eventIds);
        }
        catch (err) {
            logger.error('match_finalizer.result_provider_error', { error: err });
            throw err; // message will be retried / DLQ
        }
        // 3) Map of results with normalized fields
        const resultMap = new Map();
        scores.forEach(r => {
            resultMap.set(r.id, {
                completed: r.completed,
                scores: r.scores,
                home_team: r.home_team,
                away_team: r.away_team,
                winner: r.winner,
            });
        });
        // 4) Evaluate each ticket based on its tips and finalize atomically
        for (const snap of ticketsSnap.docs) {
            const tipsRaw = snap.get('tips') || [];
            if (!tipsRaw.length)
                continue;
            const pendingTipUpdates = [];
            const tipResults = [];
            for (let ti = 0; ti < tipsRaw.length; ti++) {
                const t = tipsRaw[ti];
                const rid0 = t?.fixtureId ?? t?.eventId;
                const rid = rid0 ? String(rid0) : '';
                let res = rid ? resultMap.get(rid) : undefined;
                if (!res && t?.eventName && t?.startTime) {
                    try {
                        const found = await (0, ApiFootballResultProvider_1.findFixtureIdByMeta)({
                            eventName: String(t.eventName),
                            startTime: new Date(String(t.startTime)).toISOString(),
                        });
                        if (found?.id) {
                            res = resultMap.get(String(found.id));
                            pendingTipUpdates.push({ index: ti, fixtureId: Number(found.id) });
                        }
                    }
                    catch (e) {
                        logger.warn('match_finalizer.fixture_resolver_failed', { error: e });
                    }
                }
                const pick = (t?.outcome ?? '').trim();
                const marketKey = t?.marketKey ?? t?.market ?? 'h2h';
                const evaluator = (0, evaluators_1.getEvaluator)(String(marketKey));
                if (!res || !evaluator) {
                    tipResults.push({
                        ...t,
                        market: String(marketKey).toUpperCase(),
                        selection: pick,
                        result: 'pending',
                        oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
                    });
                    continue;
                }
                const tipInput = {
                    marketKey: String(marketKey),
                    selection: pick,
                    odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
                };
                const outcome = evaluator.evaluate(tipInput, res);
                tipResults.push({
                    ...t,
                    market: String(marketKey).toUpperCase(),
                    selection: pick,
                    result: outcome,
                    oddsSnapshot: tipInput.odds,
                });
            }
            const uid = (snap.get('userId') || (snap.ref.parent?.parent?.id));
            await finalizeTicketAtomic(snap.ref, firebase_1.db.collection('users').doc(String(uid)), { stake: snap.get('stake'), tips: tipResults });
            if (pendingTipUpdates.length) {
                const updates = {};
                for (const u of pendingTipUpdates) {
                    updates[`tips.${u.index}.fixtureId`] = u.fixtureId;
                }
                await snap.ref.update(updates);
            }
            // Wallet credit via CoinService (idempotens – ledger kulcs: ticketId)
            {
                const payout = (0, payout_1.calcTicketPayout)(snap.get('stake'), tipResults);
                if (uid && payout > 0) {
                    const coins = Math.round(payout);
                    try {
                        await new CoinService_1.CoinService().credit(String(uid), coins, snap.id);
                    }
                    catch (e) {
                        logger.error('match_finalizer.wallet_credit_failed', { error: e, uid: String(uid), ticketId: snap.id });
                    }
                }
            }
        }
        // zárás után:
        logger.info('match_finalizer.finalize_done');
    }
    catch (e) {
        logger.error('match_finalizer.handle_error', { error: e?.message || String(e) });
        throw e;
    }
};
exports.match_finalizer = match_finalizer;
