"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dev_scheduler_kick = exports.dev_publish_finalize = void 0;
require("../global");
const https_1 = require("firebase-functions/v2/https");
const pubsub_1 = require("@google-cloud/pubsub");
const match_finalizer_1 = require("./match_finalizer");
const pubsub = new pubsub_1.PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';
// Publishes a finalize message to the result-check topic (or runs inline in dev)
exports.dev_publish_finalize = (0, https_1.onCall)(async (request) => {
    const ctx = request;
    if (!ctx.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    const fixtureId = request.data?.fixtureId;
    if (!fixtureId)
        throw new https_1.HttpsError('invalid-argument', 'fixtureId required');
    if (process.env.USE_INLINE_FINALIZER === 'true') {
        await (0, match_finalizer_1.match_finalizer)({
            data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId }), 'utf8').toString('base64'),
            attributes: { attempt: '0' },
        });
        return { status: 'OK_INLINE' };
    }
    await pubsub.topic(RESULT_TOPIC).publishMessage({
        data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId }), 'utf8'),
        attributes: { attempt: '0' },
    });
    return { status: 'OK' };
});
// Simulates a scheduler diag-check kick
exports.dev_scheduler_kick = (0, https_1.onCall)(async (request) => {
    const ctx = request;
    if (!ctx.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    if (process.env.USE_INLINE_FINALIZER === 'true') {
        await (0, match_finalizer_1.match_finalizer)({
            data: Buffer.from(JSON.stringify({ type: 'diag-check', ts: Date.now() }), 'utf8').toString('base64'),
            attributes: { attempt: '0' },
        });
        return { status: 'OK_INLINE' };
    }
    await pubsub.topic(RESULT_TOPIC).publishMessage({
        data: Buffer.from(JSON.stringify({ type: 'diag-check', ts: Date.now() }), 'utf8'),
        attributes: { attempt: '0' },
    });
    return { status: 'OK' };
});
