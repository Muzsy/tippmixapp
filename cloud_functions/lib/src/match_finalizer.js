"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.match_finalizer = void 0;
const ApiFootballResultProvider_1 = require("./services/ApiFootballResultProvider");
const CoinService_1 = require("./services/CoinService");
const firebase_1 = require("./lib/firebase");
const firestore_1 = require("firebase-admin/firestore");
const resultProvider = new ApiFootballResultProvider_1.ApiFootballResultProvider();
const coinService = new CoinService_1.CoinService();
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
    // 3) Map of results with winner name
    const resultMap = new Map();
    scores.forEach(r => {
        if (!r.completed || !r.scores) {
            resultMap.set(r.id, { completed: false });
            return;
        }
        const winner = r.scores.home > r.scores.away ? r.home_team : r.away_team;
        resultMap.set(r.id, { completed: true, winner });
    });
    // 4) Evaluate each ticket based on its tips
    const batch = firebase_1.db.batch();
    for (const snap of ticketsSnap.docs) {
        const tips = snap.get('tips') || [];
        if (!tips.length)
            continue;
        let hasPending = false;
        let hasLost = false;
        for (const t of tips) {
            const rid = t?.eventId;
            const pick = (t?.outcome ?? '').trim();
            if (!rid || !resultMap.has(rid)) {
                hasPending = true;
                continue;
            }
            const { completed, winner } = resultMap.get(rid);
            if (!completed || !winner) {
                hasPending = true;
                continue;
            }
            if (winner !== pick) {
                hasLost = true;
            }
        }
        let newStatus = 'pending';
        if (hasLost)
            newStatus = 'lost';
        else if (!hasPending)
            newStatus = 'won';
        if (newStatus !== 'pending') {
            batch.update(snap.ref, {
                status: newStatus,
                updatedAt: firestore_1.FieldValue.serverTimestamp(),
            });
            if (newStatus === 'won') {
                await coinService.credit(snap.get('uid'), snap.get('potentialProfit'), snap.id);
            }
        }
    }
    await batch.commit();
    console.log('[match_finalizer] batch commit done');
};
exports.match_finalizer = match_finalizer;
