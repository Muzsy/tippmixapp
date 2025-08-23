"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.API_FOOTBALL_KEY = void 0;
const options_1 = require("firebase-functions/v2/options");
const params_1 = require("firebase-functions/params");
// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
exports.API_FOOTBALL_KEY = (0, params_1.defineSecret)('API_FOOTBALL_KEY');
// Global options for all v2 functions – region + secret binding
(0, options_1.setGlobalOptions)({ region: 'europe-central2', secrets: [exports.API_FOOTBALL_KEY] });
