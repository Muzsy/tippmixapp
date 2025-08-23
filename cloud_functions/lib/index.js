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
exports.match_finalizer = exports.claim_daily_bonus = exports.daily_bonus = exports.onFriendRequestAccepted = exports.coin_trx = exports.onUserCreate = void 0;
require("./global");
const pubsub_1 = require("firebase-functions/v2/pubsub");
const global_1 = require("./global");
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
// Global options a global.ts-ben kerül beállításra (régió + secretek)
// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
exports.match_finalizer = (0, pubsub_1.onMessagePublished)({ topic: 'result-check', secrets: [global_1.API_FOOTBALL_KEY], retry: true }, async (event) => {
    // Védő log + guard, hogy üres event esetén is értelmezhető legyen a viselkedés
    const hasMsg = !!event?.data?.message;
    logger.info('match_finalizer.start', {
        hasMsg,
        hasData: !!event?.data?.message?.data,
        attrKeys: Object.keys(event?.data?.message?.attributes ?? {}),
    });
    if (!hasMsg) {
        logger.warn('match_finalizer.no_message');
        return;
    }
    const msg = {
        data: event.data.message?.data,
        attributes: event.data.message?.attributes,
    };
    try {
        const result = await (0, match_finalizer_1.match_finalizer)(msg);
        logger.info('match_finalizer.done', { result });
    }
    catch (e) {
        logger.error('match_finalizer.unhandled_error', { error: e?.message || String(e) });
        throw e;
    }
});
