/** @jest-environment node */
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { reserve_nickname } from '../src/username_reservation';

const RUN_E2E = process.env.RUN_E2E_EMULATOR === '1';

describe('reserve_nickname callable', () => {
  beforeAll(async () => {
    process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
    process.env.GCLOUD_PROJECT = 'demo-reserve';
    process.env.GOOGLE_CLOUD_PROJECT = 'demo-reserve';
    delete (process.env as any).GOOGLE_APPLICATION_CREDENTIALS;
    if (!getApps().length) {
      initializeApp({ projectId: 'demo-reserve' });
    }
  });

  (RUN_E2E ? it : it.skip)('reserves nickname when free', async () => {
    const db = getFirestore();
    const uid = 'u1';
    await db.collection('users').doc(uid).set({ createdAt: FieldValue.serverTimestamp() });
    const res: any = await reserve_nickname.run({ data: { nickname: 'Jani' }, auth: { uid } } as any);
    expect(res.data.success).toBe(true);
    const user = (await db.collection('users').doc(uid).get()).data();
    expect(user?.nickname).toBe('Jani');
    expect(user?.nicknameNormalized).toBe('jani');
    const reservation = await db.collection('usernames').doc('jani').get();
    expect(reservation.exists).toBe(true);
    expect(reservation.get('ownerUid')).toBe(uid);
  });

  (RUN_E2E ? it : it.skip)('rejects taken nickname', async () => {
    const db = getFirestore();
    const uid1 = 'uA';
    const uid2 = 'uB';
    await db.collection('users').doc(uid1).set({});
    await db.collection('users').doc(uid2).set({});
    // First reserve
    await reserve_nickname.run({ data: { nickname: 'Tester' }, auth: { uid: uid1 } } as any);
    // Second should fail (case-insensitive)
    await expect(
      reserve_nickname.run({ data: { nickname: 'tester' }, auth: { uid: uid2 } } as any)
    ).rejects.toMatchObject({ code: 'already-exists' });
  });
});
