"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.match_finalizer = exports.daily_bonus = exports.onFriendRequestAccepted = exports.log_coin = exports.coin_trx = exports.onUserCreate = void 0;
const pubsub_1 = require("firebase-functions/v2/pubsub");
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
// Gen2 Pub/Sub trigger (topic: result-check, region via global options)
exports.match_finalizer = (0, pubsub_1.onMessagePublished)('result-check', async (event) => {
    const msg = {
        data: event.data.message?.data,
        attributes: event.data.message?.attributes,
    };
    await (0, match_finalizer_1.match_finalizer)(msg);
});
