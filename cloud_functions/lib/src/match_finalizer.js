"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.match_finalizer = void 0;
const ApiFootballResultProvider_1 = require("./services/ApiFootballResultProvider");
const payout_1 = require("./tickets/payout");
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./lib/firebase");
const CoinService_1 = require("./services/CoinService");
const evaluators_1 = require("./evaluators");
const resultProvider = new ApiFootballResultProvider_1.ApiFootballResultProvider();
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
        tx.update(ticketRef, { status, payout, processedAt: new Date(), tips });
    });
}
const match_finalizer = async (message) => {
    const payloadStr = Buffer.from(message.data || '', 'base64').toString('utf8');
    const { job } = JSON.parse(payloadStr);
    console.log(`[match_finalizer] received job: ${job}`);
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
        scores = await resultProvider.getScores(eventIds);
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
        const tipResults = tipsRaw.map((t) => {
            const rid = t?.eventId;
            const pick = (t?.outcome ?? '').trim();
            const marketKey = t?.marketKey ?? t?.market ?? 'h2h';
            const res = rid ? resultMap.get(rid) : undefined;
            const evaluator = (0, evaluators_1.getEvaluator)(String(marketKey));
            if (!res || !evaluator) {
                return {
                    ...t,
                    market: String(marketKey).toUpperCase(),
                    selection: pick,
                    result: 'pending',
                    oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
                };
            }
            const tipInput = {
                marketKey: String(marketKey),
                selection: pick,
                odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
            };
            const outcome = evaluator.evaluate(tipInput, res);
            return {
                ...t,
                market: String(marketKey).toUpperCase(),
                selection: pick,
                result: outcome,
                oddsSnapshot: tipInput.odds,
            };
        });
        const uid = (snap.get('userId') || (snap.ref.parent?.parent?.id));
        await finalizeTicketAtomic(snap.ref, firebase_1.db.collection('users').doc(uid), { stake: snap.get('stake'), tips: tipResults });
        // Wallet credit via CoinService (idempotens – ledger: wallets/{uid}/ledger/{ticketId})
        {
            const payout = (0, payout_1.calcTicketPayout)(snap.get('stake'), tipResults);
            if (uid && payout > 0) {
                const coins = Math.round(payout);
                const cs = new CoinService_1.CoinService();
                try {
                    await cs.credit(String(uid), coins, snap.id);
                }
                catch (e) {
                    console.error('[match_finalizer] wallet credit failed', e);
                }
            }
        }
    }
    console.log('[match_finalizer] ticket finalization loop done');
};
exports.match_finalizer = match_finalizer;
