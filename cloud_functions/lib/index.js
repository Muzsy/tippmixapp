"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.match_finalizer = exports.API_FOOTBALL_KEY = exports.daily_bonus = exports.onFriendRequestAccepted = exports.log_coin = exports.coin_trx = exports.onUserCreate = void 0;
const options_1 = require("firebase-functions/v2/options");
const pubsub_1 = require("firebase-functions/v2/pubsub");
const params_1 = require("firebase-functions/params");
const match_finalizer_1 = require("./src/match_finalizer");
var coin_trx_logic_1 = require("./coin_trx.logic");
Object.defineProperty(exports, "onUserCreate", { enumerable: true, get: function () { return coin_trx_logic_1.onUserCreate; } });
Object.defineProperty(exports, "coin_trx", { enumerable: true, get: function () { return coin_trx_logic_1.coin_trx; } });
var log_coin_1 = require("./log_coin");
Object.defineProperty(exports, "log_coin", { enumerable: true, get: function () { return log_coin_1.log_coin; } });
var friend_request_1 = require("./friend_request");
Object.defineProperty(exports, "onFriendRequestAccepted", { enumerable: true, get: function () { return friend_request_1.onFriendRequestAccepted; } });
var daily_bonus_1 = require("./src/daily_bonus");
Object.defineProperty(exports, "daily_bonus", { enumerable: true, get: function () { return daily_bonus_1.daily_bonus; } });
// Global options for all v2 functions
(0, options_1.setGlobalOptions)({ region: 'europe-central2' });
// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
exports.API_FOOTBALL_KEY = (0, params_1.defineSecret)('API_FOOTBALL_KEY');
// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
exports.match_finalizer = (0, pubsub_1.onMessagePublished)({ topic: 'result-check', secrets: [exports.API_FOOTBALL_KEY] }, async (event) => {
    const msg = {
        data: event.data.message?.data,
        attributes: event.data.message?.attributes,
    };
    await (0, match_finalizer_1.match_finalizer)(msg);
});
