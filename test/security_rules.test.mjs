import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { doc, setDoc, getDoc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { before, after, beforeEach, describe, it } from 'mocha';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'tippmix-test',
    firestore: {
      rules: readFileSync('firebase.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

// Convenience helpers
const authed = (uid) => testEnv.authenticatedContext(uid).firestore();
const unauthed = () => testEnv.unauthenticatedContext().firestore();

/**
 * Seed a document completely bypassing security rules so that
 * the subsequent test can focus purely on read/update rules.
 */
const seed = async (path, data) =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });

describe('Firestore security rules', () => {
  // SR‑01 — user can create own coin_log
  it('SR-01 coin_logs create saját uid OK', async () => {
    const db = authed('user1');
    await assertSucceeds(
      setDoc(doc(db, 'coin_logs/log1'), {
        userId: 'user1',
        amount: 50,
        timestamp: serverTimestamp(),
        type: 'bet',
      })
    );
  });

  // SR‑02 — user cannot create coin_log for someone else
  it('SR-02 coin_logs create más uid FAIL', async () => {
    const db = authed('user1');
    await assertFails(
      setDoc(doc(db, 'coin_logs/log2'), {
        userId: 'user2',
        amount: 20,
        timestamp: serverTimestamp(),
        type: 'bet',
      })
    );
  });

  // SR‑03 — user can read own coin_log
  it('SR-03 coin_logs read saját uid OK', async () => {
    await seed('coin_logs/id1', {
      userId: 'user1',
      amount: 10,
      timestamp: serverTimestamp(),
      type: 'deposit',
    });
    await new Promise((r) => setTimeout(r, 500));

    const db = authed('user1');
    await assertSucceeds(getDoc(doc(db, 'coin_logs/id1')));
  });

  // SR‑04 — user cannot read others' coin_log
  it('SR-04 coin_logs read más uid FAIL', async () => {
    await seed('coin_logs/id2', {
      userId: 'user2',
      amount: 10,
      timestamp: serverTimestamp(),
      type: 'deposit',
    });
    await new Promise((r) => setTimeout(r, 500));

    const db = authed('user1');
    await assertFails(getDoc(doc(db, 'coin_logs/id2')));
  });

  // SR‑05 — user cannot update coin_log
  it('SR-05 coin_logs update tiltott', async () => {
    await seed('coin_logs/id3', {
      userId: 'user1',
      amount: 5,
      timestamp: serverTimestamp(),
      type: 'bet',
    });
    await new Promise((r) => setTimeout(r, 500));

    const db = authed('user1');
    await assertFails(updateDoc(doc(db, 'coin_logs/id3'), { amount: 6 }));
  });

  // SR‑06 — badge docs are publicly readable
  it('SR-06 badge read publikus', async () => {
    await seed('badges/b1', { key: 'b1' });

    const db = unauthed();
    await assertSucceeds(getDoc(doc(db, 'badges/b1')));
  });

  // SR‑07 — user can read own notification
  it('SR-07 notification read saját', async () => {
    await seed('notifications/user1/n/n1', { read: false });

    const db = authed('user1');
    await assertSucceeds(getDoc(doc(db, 'notifications/user1/n/n1')));
  });

  // SR‑08 — user cannot read others' notification
  it('SR-08 notification read idegen', async () => {
    await seed('notifications/user2/n/n1', { read: false });

    const db = authed('user1');
    await assertFails(getDoc(doc(db, 'notifications/user2/n/n1')));
  });

  // SR‑09 — user can mark own notification as read
  it('SR-09 notification markRead saját', async () => {
    await seed('notifications/user1/n/n1', { read: false });

    const db = authed('user1');
    await assertSucceeds(updateDoc(doc(db, 'notifications/user1/n/n1'), { read: true }));
  });

  // SR‑10 — user cannot mark others' notification as read
  it('SR-10 notification markRead idegen FAIL', async () => {
    await seed('notifications/user2/n/n2', { read: false });

    const db = authed('user1');
    await assertFails(updateDoc(doc(db, 'notifications/user2/n/n2'), { read: true }));
  });
});
