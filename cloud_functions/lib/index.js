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
exports.match_finalizer = exports.API_FOOTBALL_KEY = exports.claim_daily_bonus = exports.daily_bonus = exports.onFriendRequestAccepted = exports.coin_trx = exports.onUserCreate = void 0;
const options_1 = require("firebase-functions/v2/options");
const pubsub_1 = require("firebase-functions/v2/pubsub");
const params_1 = require("firebase-functions/params");
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
// Global options for all v2 functions
(0, options_1.setGlobalOptions)({ region: 'europe-central2' });
// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
exports.API_FOOTBALL_KEY = (0, params_1.defineSecret)('API_FOOTBALL_KEY');
// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
exports.match_finalizer = (0, pubsub_1.onMessagePublished)({ topic: 'result-check', secrets: [exports.API_FOOTBALL_KEY], retry: true }, async (event) => {
    logger.info('match_finalizer.start');
    const msg = {
        data: event.data.message?.data,
        attributes: event.data.message?.attributes,
    };
    try {
        await (0, match_finalizer_1.match_finalizer)(msg);
        logger.info('match_finalizer.success');
    }
    catch (e) {
        logger.error('match_finalizer.error', { error: e?.message || String(e) });
        throw e; // engedjük a retry-t
    }
});
