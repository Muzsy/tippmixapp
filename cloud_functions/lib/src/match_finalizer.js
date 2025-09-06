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
const provider_factory_1 = require("./services/provider_factory");
const payout_1 = require("./tickets/payout");
const firestore_1 = require("firebase-admin/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("./lib/firebase");
const pubsub_1 = require("@google-cloud/pubsub");
const CoinService_1 = require("./services/CoinService");
const evaluators_1 = require("./evaluators");
const pubsub = new pubsub_1.PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || "result-check";
const DLQ_TOPIC = process.env.DLQ_TOPIC || "result-check-dlq";
const BATCH_SIZE = Number(process.env.FINALIZER_BATCH_SIZE || 200);
const MAX_BATCHES = Number(process.env.FINALIZER_MAX_BATCHES || 3);
// After computing tip results for a ticket
async function finalizeTicketAtomic(ticketRef, ticketData) {
    const db = (0, firestore_1.getFirestore)();
    await db.runTransaction(async (tx) => {
        const tSnap = await tx.get(ticketRef);
        const t = tSnap.data();
        if (!t)
            throw new Error("Ticket not found");
        if (t.processedAt) {
            return; // idempotent exit
        }
        const tips = (ticketData.tips || []).map((x) => ({
            market: x.market,
            selection: x.selection,
            result: x.result,
            oddsSnapshot: x.oddsSnapshot,
        }));
        // Early-finalize to 'lost' if any leg is lost (final outcome)
        if (tips.some((x) => x.result === "lost")) {
            tx.update(ticketRef, { status: "lost", payout: 0, processedAt: new Date(), tips });
            return;
        }
        // Otherwise wait until no pending legs remain
        if (tips.some((x) => x.result === "pending"))
            return;
        const payout = (0, payout_1.calcTicketPayout)(ticketData.stake, tips);
        const status = (0, payout_1.deriveTicketStatus)(tips, payout);
        // users.balance helyett csak a ticket mezői frissülnek; pénzügy a CoinService-ben
        tx.update(ticketRef, { status, payout, processedAt: new Date(), tips });
    });
}
const match_finalizer = async (message) => {
    // Provider példányosítás a handler scope‑ban – Secret olvasás futásidőben
    const provider = (0, provider_factory_1.createResultProvider)();
    const attempt = Number(message?.attributes?.attempt || "0");
    logger.info("match_finalizer.handle", {
        hasData: !!message?.data,
        attempt,
        attrKeys: Object.keys(message.attributes || {}),
    });
    let job;
    let fixtureIdFromMsg;
    try {
        const payloadStr = Buffer.from(message.data || "", "base64").toString("utf8");
        const parsed = JSON.parse(payloadStr);
        job = parsed.job;
        if ((parsed.type === 'finalize' || !parsed.type) && parsed.fixtureId != null) {
            fixtureIdFromMsg = String(parsed.fixtureId);
        }
        // Batch pagination over pending tickets
        let lastDoc = undefined;
        let batches = 0;
        let anyProcessed = false;
        let morePossible = false;
        // If fixtureId is provided, process only that fixture's pending tips via index
        if (fixtureIdFromMsg) {
            const fid = fixtureIdFromMsg;
            const idxSnap = await firebase_1.db
                .collection('fixtures').doc(fid)
                .collection('ticketTips')
                .where('status', '==', 'pending')
                .limit(BATCH_SIZE)
                .get();
            if (idxSnap.empty) {
                logger.info('match_finalizer.no_pending_fixture', { fixtureId: fid });
                return 'OK';
            }
            const ticketRefs = [];
            const pairs = [];
            idxSnap.docs.forEach((d) => {
                const userId = String(d.get('userId'));
                const ticketId = String(d.get('ticketId'));
                const tipIndex = Number(d.get('tipIndex')) || 0;
                const tRef = firebase_1.db.collection('users').doc(userId).collection('tickets').doc(ticketId);
                ticketRefs.push(tRef);
                pairs.push({ userId, ticketId, tipIndex, idxRef: d.ref });
            });
            const ticketSnaps = await (0, firestore_1.getFirestore)().getAll(...ticketRefs);
            // Fetch only the given fixtureId
            let providerResultsArr;
            try {
                providerResultsArr = await provider.getScores([fid]);
            }
            catch (err) {
                logger.error('match_finalizer.result_provider_error', { error: err });
                throw err;
            }
            const providerResults = {};
            for (const r of providerResultsArr)
                providerResults[r.id] = r;
            const results = {};
            for (const [eid, r] of Object.entries(providerResults)) {
                results[eid] = {
                    completed: !!r.completed,
                    scores: r.scores,
                    home_team: r.home_team,
                    away_team: r.away_team,
                    winner: r.winner,
                };
            }
            const voidSet = new Set(Object.entries(providerResults)
                .filter(([_, r]) => r?.canceled === true || r?.status === 'canceled')
                .map(([eid]) => eid));
            // Batch index status updates together
            const batch = (0, firestore_1.getFirestore)().batch();
            for (let i = 0; i < ticketSnaps.length; i++) {
                const snap = ticketSnaps[i];
                if (!snap?.exists)
                    continue;
                const tipsRaw = snap.get('tips') || [];
                if (!tipsRaw.length)
                    continue;
                const tipResults = [];
                for (let ti = 0; ti < tipsRaw.length; ti++) {
                    const t = tipsRaw[ti];
                    // If tip already has a resolved result, keep it and do not override
                    const existing = String(t?.result || '').toLowerCase();
                    if (existing === 'won' || existing === 'lost' || existing === 'void') {
                        tipResults.push({
                            ...t,
                            market: String(t?.marketKey ?? t?.market ?? 'h2h').toUpperCase(),
                            selection: (t?.outcome ?? '').trim(),
                            result: existing,
                            oddsSnapshot: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
                        });
                        continue;
                    }
                    const pick = (t?.outcome ?? '').trim();
                    const marketKey = t?.marketKey ?? t?.market ?? 'h2h';
                    const evaluator = (0, evaluators_1.getEvaluator)(String(marketKey));
                    const evKey = String(t?.eventId ?? t?.fixtureId ?? '');
                    const normRes = evKey === fid ? results[fid] : undefined;
                    if (!normRes || !evaluator) {
                        tipResults.push({
                            ...t,
                            market: String(marketKey).toUpperCase(),
                            selection: pick,
                            result: t?.result ?? 'pending',
                            oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
                        });
                        continue;
                    }
                    const tipInput = {
                        marketKey: String(marketKey),
                        selection: pick,
                        odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
                    };
                    let result = evaluator.evaluate(tipInput, normRes);
                    if (voidSet.has(fid))
                        result = 'void';
                    tipResults.push({
                        ...t,
                        market: String(marketKey).toUpperCase(),
                        selection: pick,
                        result,
                        oddsSnapshot: tipInput.odds,
                    });
                }
                // 1) Update the specific tip's result in the ticket doc (partial progress)
                const pair = pairs[i];
                const idx = pair?.tipIndex ?? 0;
                const newStatus = tipResults[idx]?.result ?? 'pending';
                try {
                    // Firestore does not support indexed array element updates via dot-path; write the whole array
                    const updatedTips = tipsRaw.map((orig, ti) => ti === idx
                        ? { ...orig, result: newStatus, fixtureId: Number(fid) }
                        : orig);
                    await snap.ref.update({ tips: updatedTips });
                }
                catch (e) {
                    logger.error('match_finalizer.partial_update_failed', { error: String(e), ticketId: snap.id, idx });
                }
                // 2) Decide if the ticket can be finalized now (any lost OR no pending)
                const shouldFinalize = tipResults.some((t) => t.result === 'lost') ||
                    !tipResults.some((t) => t.result === 'pending');
                if (shouldFinalize) {
                    await finalizeTicketAtomic(snap.ref, { stake: snap.get('stake'), tips: tipResults });
                    // Wallet credit via CoinService (idempotent)
                    const uid = snap.get('userId') || snap.ref.parent?.parent?.id;
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
                // 3) sync index doc status for this pair (batched)
                batch.set(pair.idxRef, { status: newStatus, updatedAt: new Date() }, { merge: true });
            }
            await batch.commit();
            // If we hit the page size, re-enqueue to continue processing this fixture
            if (idxSnap.size >= BATCH_SIZE) {
                await pubsub.topic(RESULT_TOPIC).publishMessage({
                    data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: fid })),
                    attributes: { attempt: '0' },
                });
                logger.info('match_finalizer.enqueue_next_fixture_page', { fixtureId: fid });
            }
            logger.info('match_finalizer.finalize_done_fixture', { fixtureId: fid, count: ticketSnaps.length });
            return 'OK';
        }
        while (batches < MAX_BATCHES) {
            const filterUid = process.env.FILTER_UID;
            let q;
            if (filterUid) {
                q = firebase_1.db
                    .collection('users')
                    .doc(String(filterUid))
                    .collection('tickets')
                    .where('status', '==', 'pending')
                    .limit(BATCH_SIZE);
            }
            else {
                q = firebase_1.db
                    .collectionGroup("tickets")
                    .where("status", "==", "pending")
                    .limit(BATCH_SIZE);
            }
            const ticketsSnap = await q.get();
            if (ticketsSnap.empty) {
                logger.info("match_finalizer.no_pending_batch", { batch: batches });
                break;
            }
            anyProcessed = true;
            if (ticketsSnap.size === BATCH_SIZE) {
                morePossible = true;
            }
            logger.info("match_finalizer.pending_tickets_batch", {
                batch: batches,
                count: ticketsSnap.size,
            });
            // Gather unique eventIds from this batch's tips[] arrays (multi-event tickets támogatás)
            const eventIdSet = new Set();
            for (const doc of ticketsSnap.docs) {
                const tips = doc.get("tips") || [];
                for (const t of tips) {
                    if (t && typeof t.eventId === "string" && t.eventId.trim()) {
                        eventIdSet.add(t.eventId.trim());
                    }
                }
            }
            // Fixture ID feloldás (ha a tipben nincs eltárolva)
            const fixtureMap = {};
            for (const doc of ticketsSnap.docs) {
                const tips = doc.get("tips") || [];
                for (const t of tips) {
                    if (!t.fixtureId && t.eventName && t.startTime) {
                        const found = await (0, ApiFootballResultProvider_1.findFixtureIdByMeta)({
                            eventName: t.eventName,
                            startTime: t.startTime,
                        });
                        if (found?.id) {
                            fixtureMap[t.eventId] = found.id;
                            eventIdSet.add(String(found.id));
                        }
                    }
                }
            }
            const eventIds = Array.from(eventIdSet);
            logger.info("match_finalizer.unique_events_batch", {
                batch: batches,
                count: eventIds.length,
            });
            // 2) Fetch scores
            let providerResultsArr;
            try {
                providerResultsArr = await provider.getScores(eventIds);
            }
            catch (err) {
                logger.error("match_finalizer.result_provider_error", { error: err });
                throw err; // message will be retried / DLQ
            }
            const providerResults = {};
            for (const r of providerResultsArr) {
                providerResults[r.id] = r;
            }
            // Normalize provider result → evaluator input; canceled = void
            const results = {};
            for (const [eid, r] of Object.entries(providerResults)) {
                results[eid] = {
                    completed: !!r.completed,
                    scores: r.scores,
                    home_team: r.home_team,
                    away_team: r.away_team,
                    winner: r.winner,
                };
            }
            // canceled/void flag támogatása
            const voidSet = new Set(Object.entries(providerResults)
                .filter(([_, r]) => r?.canceled === true || r?.status === "canceled")
                .map(([eid]) => eid));
            // 4) Evaluate each ticket based on its tips and finalize atomically
            for (const snap of ticketsSnap.docs) {
                const tipsRaw = snap.get("tips") || [];
                if (!tipsRaw.length)
                    continue;
                const pendingTipUpdates = [];
                const tipResults = [];
                for (let ti = 0; ti < tipsRaw.length; ti++) {
                    const t = tipsRaw[ti];
                    // Preserve already-resolved tips; do not re-evaluate
                    const existing = String(t?.result || '').toLowerCase();
                    if (existing === 'won' || existing === 'lost' || existing === 'void') {
                        tipResults.push({
                            ...t,
                            market: String(t?.marketKey ?? t?.market ?? 'h2h').toUpperCase(),
                            selection: (t?.outcome ?? '').trim(),
                            result: existing,
                            oddsSnapshot: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
                        });
                        continue;
                    }
                    const fid = fixtureMap[t.eventId];
                    const normRes = results[t.eventId] || (fid ? results[String(fid)] : undefined);
                    const pick = (t?.outcome ?? "").trim();
                    const marketKey = t?.marketKey ?? t?.market ?? "h2h";
                    const evaluator = (0, evaluators_1.getEvaluator)(String(marketKey));
                    if (!normRes || !evaluator) {
                        tipResults.push({
                            ...t,
                            market: String(marketKey).toUpperCase(),
                            selection: pick,
                            result: "pending",
                            oddsSnapshot: t?.odds ?? t?.oddsSnapshot,
                        });
                        continue;
                    }
                    const tipInput = {
                        marketKey: String(marketKey),
                        selection: pick,
                        odds: Number(t?.odds ?? t?.oddsSnapshot ?? 1.0),
                    };
                    let result = evaluator.evaluate(tipInput, normRes);
                    const voidKey = fid ? String(fid) : t.eventId;
                    if (voidSet.has(voidKey))
                        result = "void";
                    tipResults.push({
                        ...t,
                        market: String(marketKey).toUpperCase(),
                        selection: pick,
                        result,
                        oddsSnapshot: tipInput.odds,
                    });
                    if (!t.fixtureId && fid) {
                        pendingTipUpdates.push({ index: ti, fixtureId: fid });
                    }
                }
                const uid = snap.get("userId") || snap.ref.parent?.parent?.id;
                await finalizeTicketAtomic(snap.ref, { stake: snap.get("stake"), tips: tipResults });
                if (pendingTipUpdates.length) {
                    const updates = {};
                    for (const u of pendingTipUpdates) {
                        updates[`tips.${u.index}.fixtureId`] = u.fixtureId;
                    }
                    await snap.ref.update(updates);
                }
                // Wallet credit via CoinService (idempotens – ledger kulcs: ticketId)
                {
                    const payout = (0, payout_1.calcTicketPayout)(snap.get("stake"), tipResults);
                    if (uid && payout > 0) {
                        const coins = Math.round(payout);
                        try {
                            await new CoinService_1.CoinService().credit(String(uid), coins, snap.id);
                        }
                        catch (e) {
                            logger.error("match_finalizer.wallet_credit_failed", {
                                error: e,
                                uid: String(uid),
                                ticketId: snap.id,
                            });
                        }
                    }
                }
            } // for ticketsSnap.docs
            // end of batch processing for this page
            // No explicit pagination cursor to avoid composite index requirement
            lastDoc = undefined;
            batches += 1;
        } // while
        if (morePossible) {
            await pubsub.topic(RESULT_TOPIC).publishMessage({
                data: Buffer.from(JSON.stringify({ job })),
                attributes: { attempt: "0" },
            });
            logger.info("match_finalizer.enqueue_next_batch", { next: true });
        }
        if (!anyProcessed) {
            logger.info("match_finalizer.no_pending");
        }
        logger.info("match_finalizer.finalize_done");
        return "OK";
    }
    catch (e) {
        logger.error("match_finalizer.handle_error", {
            error: e?.message || String(e),
            attempt,
        });
        try {
            if (attempt >= 2) {
                await pubsub
                    .topic(DLQ_TOPIC)
                    .publishMessage({
                    data: Buffer.from(JSON.stringify({ job })),
                    attributes: { attempt: String(attempt) },
                });
                logger.error("match_finalizer.sent_to_dlq", { attempt });
                return "DLQ";
            }
            else {
                await pubsub
                    .topic(RESULT_TOPIC)
                    .publishMessage({
                    data: Buffer.from(JSON.stringify({ job })),
                    attributes: { attempt: String(attempt + 1) },
                });
                logger.warn("match_finalizer.requeued", {
                    nextAttempt: attempt + 1,
                    job,
                });
                return "RETRY";
            }
        }
        catch (pubErr) {
            logger.error("match_finalizer.requeue_failed", { error: String(pubErr) });
        }
        return "RETRY";
    }
};
exports.match_finalizer = match_finalizer;
