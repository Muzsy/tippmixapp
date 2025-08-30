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
exports.match_finalizer = exports.reserve_nickname = exports.admin_coin_ops = exports.claim_daily_bonus = exports.daily_bonus = exports.onFriendRequestAccepted = exports.coin_trx = exports.onUserCreate = void 0;
require("./global");
const eventarc_1 = require("firebase-functions/v2/eventarc");
const logger = __importStar(require("firebase-functions/logger"));
const match_finalizer_1 = require("./src/match_finalizer");
var coin_trx_logic_1 = require("./coin_trx.logic");
Object.defineProperty(exports, "onUserCreate", { enumerable: true, get: function () { return coin_trx_logic_1.onUserCreate; } });
Object.defineProperty(exports, "coin_trx", { enumerable: true, get: function () { return coin_trx_logic_1.coin_trx; } });
// log_coin kivezetve (Step4) – végleges törléshez futtasd egyszer:
// firebase functions:delete log_coin --region=europe-central2 --force
var friend_request_1 = require("./friend_request");
Object.defineProperty(exports, "onFriendRequestAccepted", { enumerable: true, get: function () { return friend_request_1.onFriendRequestAccepted; } });
var daily_bonus_1 = require("./src/daily_bonus");
Object.defineProperty(exports, "daily_bonus", { enumerable: true, get: function () { return daily_bonus_1.daily_bonus; } });
var bonus_claim_1 = require("./src/bonus_claim");
Object.defineProperty(exports, "claim_daily_bonus", { enumerable: true, get: function () { return bonus_claim_1.claim_daily_bonus; } });
var admin_coin_ops_1 = require("./admin_coin_ops");
Object.defineProperty(exports, "admin_coin_ops", { enumerable: true, get: function () { return admin_coin_ops_1.admin_coin_ops; } });
var username_reservation_1 = require("./src/username_reservation");
Object.defineProperty(exports, "reserve_nickname", { enumerable: true, get: function () { return username_reservation_1.reserve_nickname; } });
// Global options a global.ts-ben kerül beállításra (régió + secretek)
// Gen2 Pub/Sub trigger (topic set by deploy), handle raw CloudEvent to avoid
// v2 pubsub wrapper constructing Message on undefined event.data.
exports.match_finalizer = (0, eventarc_1.onCustomEventPublished)('google.cloud.pubsub.topic.v1.messagePublished', async (event) => {
    // Védő log + guard, hogy üres event esetén is értelmezhető legyen a viselkedés
    const ev = event;
    let dataB64 = ev?.data?.message?.data;
    let attrs = ev?.data?.message?.attributes;
    // Eventarc CUSTOM_PUBSUB eset: data.data / data.attributes
    if (!dataB64 && ev?.data?.data)
        dataB64 = ev.data.data;
    if (!attrs && ev?.data?.attributes)
        attrs = ev.data.attributes;
    // Ha továbbra sincs dataB64, próbáljuk az egész data objektumot JSON-ként base64-elni
    if (!dataB64 && ev?.data) {
        try {
            dataB64 = Buffer.from(JSON.stringify(ev.data), 'utf8').toString('base64');
        }
        catch (_) { }
    }
    const hasMsg = !!dataB64;
    let eventType;
    try {
        const raw = dataB64;
        if (raw) {
            const jsonStr = Buffer.from(raw, 'base64').toString('utf8');
            const parsed = JSON.parse(jsonStr);
            if (parsed && typeof parsed === 'object' && parsed.type === 'diag-check') {
                eventType = 'diag-check';
            }
        }
    }
    catch (_) {
        // ignore parse errors – not a fatal condition for logging
    }
    logger.info('match_finalizer.start', {
        hasMsg,
        hasData: !!dataB64,
        attrKeys: Object.keys(attrs ?? {}),
        ...(eventType ? { eventType } : {}),
    });
    if (!hasMsg) {
        // INFO szintre állítva – nem tekintjük hibának a hiányzó üzenetet
        logger.info('match_finalizer.no_message');
        return;
    }
    const msg = { data: dataB64, attributes: attrs };
    try {
        const result = await (0, match_finalizer_1.match_finalizer)(msg);
        logger.info('match_finalizer.done', { result });
    }
    catch (e) {
        logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
        throw e;
    }
});
