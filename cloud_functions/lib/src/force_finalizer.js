"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.force_finalizer = void 0;
require("../global");
const https_1 = require("firebase-functions/v2/https");
const pubsub_1 = require("@google-cloud/pubsub");
const match_finalizer_1 = require("./match_finalizer");
const pubsub = new pubsub_1.PubSub();
const RESULT_TOPIC = process.env.RESULT_TOPIC || 'result-check';
exports.force_finalizer = (0, https_1.onCall)(async (request) => {
    const ctx = request;
    if (!ctx.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    const isAdmin = Boolean(ctx.auth.token?.admin);
    const devOverride = Boolean(request.data?.devOverride);
    const allowDev = process.env.ALLOW_DEV_FORCE_FINALIZER === 'true' && devOverride;
    if (!isAdmin && !allowDev) {
        throw new https_1.HttpsError('permission-denied', 'Admin only');
    }
    const payload = {
        type: 'final-sweep',
        requestedBy: ctx.auth.uid,
        ts: Date.now(),
    };
    if (process.env.USE_INLINE_FINALIZER === 'true') {
        // Inline run for dev/offline determinism
        await (0, match_finalizer_1.match_finalizer)({
            data: Buffer.from(JSON.stringify({ type: 'final-sweep' }), 'utf8').toString('base64'),
            attributes: { attempt: '0' },
        });
        return { status: 'OK_INLINE' };
    }
    else {
        await pubsub.topic(RESULT_TOPIC).publishMessage({
            data: Buffer.from(JSON.stringify(payload), 'utf8'),
            attributes: { attempt: '0' },
        });
        return { status: 'OK' };
    }
});
