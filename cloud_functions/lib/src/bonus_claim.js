"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.claim_daily_bonus = void 0;
require("../global");
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./lib/firebase");
const CoinService_1 = require("./services/CoinService");
function ymdUtc(d = new Date()) {
    const iso = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate())).toISOString().slice(0, 10);
    return iso.replace(/-/g, '');
}
exports.claim_daily_bonus = (0, https_1.onCall)(async (request) => {
    const ctx = request;
    if (!ctx.auth?.uid)
        throw new https_1.HttpsError('unauthenticated', 'Sign in required');
    const uid = ctx.auth.uid;
    const rulesSnap = await firebase_1.db.doc('system_configs/bonus_rules').get();
    if (!rulesSnap.exists)
        throw new https_1.HttpsError('failed-precondition', 'Bonus rules missing');
    const rules = rulesSnap.data();
    if (rules.killSwitch)
        throw new https_1.HttpsError('failed-precondition', 'Bonus disabled');
    if (!rules.daily?.enabled)
        throw new https_1.HttpsError('failed-precondition', 'Daily bonus disabled');
    const amount = rules.daily.amount;
    const cooldownH = rules.daily.cooldownHours ?? 24;
    const now = new Date();
    const todayKey = ymdUtc(now);
    const refId = `bonus:daily:${todayKey}`;
    const bonusStateRef = firebase_1.db.doc(`users/${uid}/bonus_state`);
    const walletRef = firebase_1.db.collection('users').doc(uid).collection('wallet').doc('main');
    await firebase_1.db.runTransaction(async (t) => {
        const [stateDoc, walletDoc] = await Promise.all([t.get(bonusStateRef), t.get(walletRef)]);
        const state = stateDoc.exists ? stateDoc.data() : {};
        const lock = state.lock ?? { active: false, expiresAt: null };
        if (lock.active)
            throw new https_1.HttpsError('aborted', 'Bonus is locked, try again');
        const nowTs = firestore_1.Timestamp.now();
        const cooldownUntil = state.dailyCooldownUntil ?? null;
        if (cooldownUntil && nowTs.toMillis() < cooldownUntil.toMillis()) {
            throw new https_1.HttpsError('failed-precondition', 'Cooldown');
        }
        // Lock on
        t.set(bonusStateRef, { lock: { active: true, expiresAt: firestore_1.Timestamp.fromMillis(nowTs.toMillis() + 60000) } }, { merge: true });
        const before = walletDoc.get('coins') ?? 0;
        const svc = new CoinService_1.CoinService();
        await svc.credit(uid, amount, refId, 'daily_bonus', t, before);
        const nextCooldown = firestore_1.Timestamp.fromMillis(nowTs.toMillis() + cooldownH * 3600 * 1000);
        t.set(bonusStateRef, {
            lastDailyClaimAt: nowTs,
            dailyCooldownUntil: nextCooldown,
            lastAppliedVersion: rules.version,
            lock: { active: false, expiresAt: null }
        }, { merge: true });
    });
    return { ok: true, amount };
});
