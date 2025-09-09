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
exports.match_finalizer = exports.onVoteDelete = exports.onVoteCreate = exports.dev_scheduler_kick = exports.dev_publish_finalize = exports.force_finalizer = exports.finalize_publish = exports.backfill_fixture_index = exports.onTicketWritten_indexFixture = exports.reserve_nickname = exports.admin_coin_ops = exports.claim_daily_bonus = exports.onFriendRequestAccepted = exports.coin_trx = exports.onUserCreate = void 0;
require("./global");
require("./src/lib/firebase");
const pubsub_1 = require("firebase-functions/v2/pubsub");
const logger = __importStar(require("firebase-functions/logger"));
const match_finalizer_1 = require("./src/match_finalizer");
var coin_trx_logic_1 = require("./coin_trx.logic");
Object.defineProperty(exports, "onUserCreate", { enumerable: true, get: function () { return coin_trx_logic_1.onUserCreate; } });
Object.defineProperty(exports, "coin_trx", { enumerable: true, get: function () { return coin_trx_logic_1.coin_trx; } });
// log_coin kivezetve (Step4) – végleges törléshez futtasd egyszer:
// firebase functions:delete log_coin --region=europe-central2 --force
var friend_request_1 = require("./friend_request");
Object.defineProperty(exports, "onFriendRequestAccepted", { enumerable: true, get: function () { return friend_request_1.onFriendRequestAccepted; } });
// cost-hardening: disable mass daily bonus cron (use claim_daily_bonus instead)
// export { daily_bonus } from './src/daily_bonus';
var bonus_claim_1 = require("./src/bonus_claim");
Object.defineProperty(exports, "claim_daily_bonus", { enumerable: true, get: function () { return bonus_claim_1.claim_daily_bonus; } });
var admin_coin_ops_1 = require("./admin_coin_ops");
Object.defineProperty(exports, "admin_coin_ops", { enumerable: true, get: function () { return admin_coin_ops_1.admin_coin_ops; } });
var username_reservation_1 = require("./src/username_reservation");
Object.defineProperty(exports, "reserve_nickname", { enumerable: true, get: function () { return username_reservation_1.reserve_nickname; } });
var fixtures_index_1 = require("./fixtures_index");
Object.defineProperty(exports, "onTicketWritten_indexFixture", { enumerable: true, get: function () { return fixtures_index_1.onTicketWritten_indexFixture; } });
var backfill_fixture_index_1 = require("./backfill_fixture_index");
Object.defineProperty(exports, "backfill_fixture_index", { enumerable: true, get: function () { return backfill_fixture_index_1.backfill_fixture_index; } });
var finalize_publish_1 = require("./src/finalize_publish");
Object.defineProperty(exports, "finalize_publish", { enumerable: true, get: function () { return finalize_publish_1.finalize_publish; } });
var force_finalizer_1 = require("./src/force_finalizer");
Object.defineProperty(exports, "force_finalizer", { enumerable: true, get: function () { return force_finalizer_1.force_finalizer; } });
var dev_pubsub_emulator_1 = require("./src/dev_pubsub_emulator");
Object.defineProperty(exports, "dev_publish_finalize", { enumerable: true, get: function () { return dev_pubsub_emulator_1.dev_publish_finalize; } });
Object.defineProperty(exports, "dev_scheduler_kick", { enumerable: true, get: function () { return dev_pubsub_emulator_1.dev_scheduler_kick; } });
var forumVotes_1 = require("./src/triggers/forumVotes");
Object.defineProperty(exports, "onVoteCreate", { enumerable: true, get: function () { return forumVotes_1.onVoteCreate; } });
Object.defineProperty(exports, "onVoteDelete", { enumerable: true, get: function () { return forumVotes_1.onVoteDelete; } });
// Global options a global.ts-ben kerül beállításra (régió + secretek)
// Gen2 Pub/Sub trigger – topic: result-check
exports.match_finalizer = (0, pubsub_1.onMessagePublished)('result-check', async (event) => {
    const dataB64 = event.data.message?.data;
    const attrs = event.data.message?.attributes || undefined;
    const hasMsg = !!dataB64;
    let eventType;
    try {
        if (dataB64) {
            const jsonStr = Buffer.from(dataB64, 'base64').toString('utf8');
            const parsed = JSON.parse(jsonStr);
            if (parsed && typeof parsed === 'object' && parsed.type === 'diag-check') {
                eventType = 'diag-check';
            }
        }
    }
    catch (_) { }
    logger.info('match_finalizer.start', {
        hasMsg,
        hasData: !!dataB64,
        attrKeys: Object.keys(attrs ?? {}),
        ...(eventType ? { eventType } : {}),
    });
    if (!hasMsg) {
        logger.debug('match_finalizer.no_message');
        return;
    }
    const msg = { data: dataB64, attributes: attrs };
    try {
        const result = await (0, match_finalizer_1.match_finalizer)(msg);
        logger.debug('match_finalizer.done', { result });
    }
    catch (e) {
        logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
        throw e;
    }
});
