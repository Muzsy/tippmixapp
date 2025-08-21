"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.match_finalizer = void 0;
const ApiFootballResultProvider_1 = require("./services/ApiFootballResultProvider");
const payout_1 = require("./tickets/payout");
const firestore_1 = require("firebase-admin/firestore");
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
    console.log('[match_finalizer] received raw message');
    try {
        console.log('[match_finalizer] payload:', JSON.stringify(message?.data || {}));
    }
    catch { }
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
        console.log('[match_finalizer] no pending tickets – exit');
        return;
    }
    console.log('[match_finalizer] found %d pending tickets', ticketsSnap.size);
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
    console.log(`[match_finalizer] found ${eventIds.length} unique eventIds`);
    // 2) Fetch scores
    let scores;
    try {
        scores = await provider.getScores(eventIds);
    }
    catch (err) {
        console.error('[match_finalizer] ResultProvider error', err);
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
                    console.warn('[match_finalizer] fixture resolver failed', e);
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
                    console.error('[match_finalizer] wallet credit failed', e);
                }
            }
        }
    }
    // zárás után:
    console.log('[match_finalizer] finalize done for batch');
};
exports.match_finalizer = match_finalizer;
