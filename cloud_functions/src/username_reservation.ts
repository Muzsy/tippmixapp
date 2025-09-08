import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { db } from './lib/firebase';
import { normalizeNickname } from './utils/normalize';

interface ReserveData { nickname: string }

export const reserve_nickname = onCall(async (request) => {
  const ctx = request as any;
  if (!ctx.auth || !ctx.auth.uid) throw new HttpsError('unauthenticated', 'Login required');
  const uid = ctx.auth.uid as string;
  const { nickname } = (request.data || {}) as ReserveData;
  if (typeof nickname !== 'string' || !nickname.trim()) {
    throw new HttpsError('invalid-argument', 'nickname is required');
  }
  if (nickname.length < 3 || nickname.length > 20) {
    throw new HttpsError('invalid-argument', 'nickname length invalid');
  }
  const norm = normalizeNickname(nickname);
  const userRef = db.collection('users').doc(uid);
  const resRef = db.collection('usernames').doc(norm);

  try {
    await db.runTransaction(async (tx) => {
      const [resSnap, userSnap] = await Promise.all([tx.get(resRef), tx.get(userRef)]);
      const currentNorm = (userSnap.data()?.nicknameNormalized as string | undefined) || undefined;
      if (resSnap.exists && resSnap.get('ownerUid') !== uid) {
        throw new HttpsError('already-exists', 'nickname taken');
      }
      // Create/merge reservation
      tx.set(resRef, { ownerUid: uid, createdAt: FieldValue.serverTimestamp() }, { merge: true });
      // Update user fields
      tx.set(
        userRef,
        { nickname, nicknameNormalized: norm, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      // If user had a different reservation, release it
      if (currentNorm && currentNorm !== norm) {
        const oldRef = db.collection('usernames').doc(currentNorm);
        tx.delete(oldRef);
      }
    });
    logger.debug('reserve_nickname.ok', { uid, nickname, norm });
    return { success: true, norm };
  } catch (e: any) {
    if (e instanceof HttpsError) throw e;
    logger.error('reserve_nickname.error', { uid, nickname, error: e?.message || String(e) });
    throw new HttpsError('internal', 'reservation failed');
  }
});
