"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = void 0;
const app_1 = require("firebase-admin/app");
const options_1 = require("firebase-functions/v2/options");
const global_1 = require("../../global");
const firestore_1 = require("firebase-admin/firestore");
if (!(0, app_1.getApps)().length) {
    (0, app_1.initializeApp)();
    // Apply global function options after admin initialization
    (0, options_1.setGlobalOptions)({
        region: 'europe-central2',
        secrets: [global_1.API_FOOTBALL_KEY],
        concurrency: 10,
        maxInstances: 10,
        cpu: 1,
        memory: '512MiB',
    });
}
exports.db = (0, firestore_1.getFirestore)();
