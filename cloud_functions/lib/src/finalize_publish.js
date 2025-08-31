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
exports.finalize_publish = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const pubsub_1 = require("@google-cloud/pubsub");
const pubsub = new pubsub_1.PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';
exports.finalize_publish = (0, https_1.onRequest)({ timeoutSeconds: 120 }, async (req, res) => {
    try {
        const token = req.header('x-admin-token');
        const expected = process.env.BACKFILL_TOKEN; // reuse same admin token for simplicity
        if (expected && token !== expected) {
            res.status(403).send('Forbidden');
            return;
        }
        const body = (req.method === 'POST' ? req.body : undefined) || {};
        const single = req.query.fixtureId;
        const many = Array.isArray(body.fixtureIds) ? body.fixtureIds : [];
        const ids = [];
        if (single)
            ids.push(String(single));
        for (const x of many)
            if (x != null)
                ids.push(String(x));
        if (!ids.length) {
            res.status(400).json({ ok: false, error: 'Missing fixtureId(s)' });
            return;
        }
        let published = 0;
        for (const fid of ids) {
            await pubsub.topic(RESULT_TOPIC).publishMessage({
                data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: fid })),
                attributes: { attempt: '0' },
            });
            published++;
        }
        logger.info('finalize_publish.published', { count: published });
        res.json({ ok: true, published });
    }
    catch (e) {
        logger.error('finalize_publish.error', { error: e?.message || String(e) });
        res.status(500).json({ ok: false, error: e?.message || String(e) });
    }
});
