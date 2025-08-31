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
exports.backfill_fixture_index = void 0;
require("./global");
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("./src/lib/firebase");
const fixtures_index_1 = require("./fixtures_index");
exports.backfill_fixture_index = (0, https_1.onRequest)({ timeoutSeconds: 540 }, async (req, res) => {
    const token = req.header('x-admin-token');
    const expected = process.env.BACKFILL_TOKEN;
    if (!expected || token !== expected) {
        res.status(403).send('Forbidden');
        return;
    }
    const limit = Math.max(1, Math.min(Number(req.query.limit) || 5000, 50000));
    const pageSize = Math.max(50, Math.min(Number(req.query.pageSize) || 300, 500));
    let processed = 0;
    let lastSnap = undefined;
    while (processed < limit) {
        const base = firebase_1.db.collectionGroup('tickets').orderBy('__name__');
        const q = lastSnap ? base.startAfter(lastSnap).limit(pageSize) : base.limit(pageSize);
        const snap = await q.get();
        if (snap.empty)
            break;
        for (const doc of snap.docs) {
            const data = doc.data();
            const uid = data.userId || doc.ref.parent?.parent?.id || '';
            const ticketId = doc.id;
            try {
                await (0, fixtures_index_1.upsertFixtureIndex)(uid, ticketId, data);
                processed++;
            }
            catch (e) {
                logger.error('backfill_fixture_index.error', { id: ticketId, error: e?.message || String(e) });
            }
            if (processed >= limit)
                break;
        }
        lastSnap = snap.docs[snap.docs.length - 1];
        if (snap.size < pageSize)
            break;
    }
    res.json({ ok: true, processed });
});
