import '../global';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from './lib/firebase';
import { CoinService } from './services/CoinService';

type BonusRules = {
  killSwitch: boolean;
  version: number;
  daily?: { enabled: boolean; amount: number; cooldownHours: number; maxPerDay?: number };
};

function ymdUtc(d = new Date()): string {
  const iso = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate())).toISOString().slice(0,10);
  return iso.replace(/-/g, '');
}

export const claim_daily_bonus = onCall(async (request) => {
  const ctx: any = request;
  if (!ctx.auth?.uid) throw new HttpsError('unauthenticated', 'Sign in required');
  const uid = ctx.auth.uid as string;

  const rulesSnap = await db.doc('system_configs/bonus_rules').get();
  if (!rulesSnap.exists) throw new HttpsError('failed-precondition', 'Bonus rules missing');
  const rules = rulesSnap.data() as BonusRules;
  if (rules.killSwitch) throw new HttpsError('failed-precondition', 'Bonus disabled');
  if (!rules.daily?.enabled) throw new HttpsError('failed-precondition', 'Daily bonus disabled');
  const amount = rules.daily.amount;
  const cooldownH = rules.daily.cooldownHours ?? 24;
  const now = new Date();
  const todayKey = ymdUtc(now);
  const refId = `bonus:daily:${todayKey}`;

  const bonusStateRef = db
    .collection('users').doc(uid)
    .collection('bonus_state').doc('state');
  const walletRef = db.collection('users').doc(uid).collection('wallet').doc('main');

  await db.runTransaction(async (t) => {
    const [stateDoc, walletDoc] = await Promise.all([t.get(bonusStateRef), t.get(walletRef)]);
    const state = stateDoc.exists ? (stateDoc.data() as any) : {};
    const lock = state.lock ?? { active: false, expiresAt: null };
    if (lock.active) throw new HttpsError('aborted', 'Bonus is locked, try again');
    const nowTs = Timestamp.now();
    const cooldownUntil: Timestamp | null = state.dailyCooldownUntil ?? null;
    if (cooldownUntil && nowTs.toMillis() < cooldownUntil.toMillis()) {
      throw new HttpsError('failed-precondition', 'Cooldown');
    }
    // Lock on
    t.set(bonusStateRef, { lock: { active: true, expiresAt: Timestamp.fromMillis(nowTs.toMillis() + 60000) } }, { merge: true });
    const before = (walletDoc.get('coins') as number) ?? 0;
    const svc = new CoinService();
    await svc.credit(uid, amount, refId, 'daily_bonus', t, before);
    const nextCooldown = Timestamp.fromMillis(nowTs.toMillis() + cooldownH * 3600 * 1000);
    t.set(bonusStateRef, {
      lastDailyClaimAt: nowTs,
      dailyCooldownUntil: nextCooldown,
      lastAppliedVersion: rules.version,
      lock: { active: false, expiresAt: null }
    }, { merge: true });
  });
  return { ok: true, amount };
});
