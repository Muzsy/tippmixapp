"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.API_FOOTBALL_KEY = void 0;
const params_1 = require("firebase-functions/params");
// Secret from Secret Manager (Console → Secret Manager → API_FOOTBALL_KEY)
exports.API_FOOTBALL_KEY = (0, params_1.defineSecret)('API_FOOTBALL_KEY');
// Global options are applied after admin initialization in src/lib/firebase.ts
