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
  // SR‑01 — user can create public_feed post as self
  it('SR-01 public_feed create saját uid OK', async () => {
    const db = authed('user1');
    await assertSucceeds(
      setDoc(doc(db, 'public_feed/post1'), {
        userId: 'user1',
        text: 'hello',
        createdAt: serverTimestamp(),
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
        createdAt: serverTimestamp(),
        type: 'bet',
      })
    );
  });

  // SR‑03 — user can read own ledger entry
  it('SR-03 ledger read saját uid OK', async () => {
    await seed('users/user1/ledger/id1', {
      amount: 10,
      createdAt: serverTimestamp(),
      type: 'deposit',
    });
    await new Promise((r) => setTimeout(r, 500));

    const db = authed('user1');
    await assertSucceeds(getDoc(doc(db, 'users/user1/ledger/id1')));
  });

  // SR‑04 — user cannot read others' coin_log
  it('SR-04 coin_logs read más uid FAIL', async () => {
    await seed('coin_logs/id2', {
      userId: 'user2',
      amount: 10,
      createdAt: serverTimestamp(),
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
      createdAt: serverTimestamp(),
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
    await seed('users/user1/notifications/n1', { read: false });

    const db = authed('user1');
    await assertSucceeds(getDoc(doc(db, 'users/user1/notifications/n1')));
  });

  // SR‑08 — user cannot read others' notification
  it('SR-08 notification read idegen', async () => {
    await seed('users/user2/notifications/n1', { read: false });

    const db = authed('user1');
    await assertFails(getDoc(doc(db, 'users/user2/notifications/n1')));
  });

  // SR‑09 — user can mark own notification as read
  it('SR-09 notification markRead saját', async () => {
    await seed('users/user1/notifications/n1', { read: false });

    const db = authed('user1');
    await assertSucceeds(updateDoc(doc(db, 'users/user1/notifications/n1'), { read: true }));
  });

  // SR‑10 — user cannot mark others' notification as read
  it('SR-10 notification markRead idegen FAIL', async () => {
    await seed('users/user2/notifications/n2', { read: false });

    const db = authed('user1');
    await assertFails(updateDoc(doc(db, 'users/user2/notifications/n2'), { read: true }));
  });

  // SR‑11 — authenticated user can read other profiles (leaderboard)
  it('SR-11 users read toplista OK', async () => {
    await seed('users/user1', { displayName: 'Alice' });
    await new Promise((r) => setTimeout(r, 500));

    const db = authed('user2');
    await assertSucceeds(getDoc(doc(db, 'users/user1')));
  });

  // SR‑12 — user can write to own wallet
  it('SR-12 wallets write saját uid FAIL', async () => {
    const db = authed('user1');
    await assertFails(
      setDoc(doc(db, 'wallets/user1'), {
        balance: 100,
      })
    );
  });

  // SR‑13 — user can create his own ticket
  it('SR-13 tickets create saját uid OK', async () => {
    const db = authed('user1');
    const id = `user1_${Date.now()}`;
    await assertSucceeds(
      setDoc(doc(db, `tickets/${id}`), {
        id,
        ownerId: 'user1',
        tips: [],
        stake: 5,
        totalOdd: 2.4,
        potentialWin: 12,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        status: 'pending',
      })
    );
  });

  // SR‑14 — user can read & write his own settings
  it('SR-14 settings read/write saját uid OK', async () => {
    const db = authed('user1');
    const ref = doc(db, 'users/user1/settings/theme');
    await assertSucceeds(setDoc(ref, { value: 'dark' }));
    await assertSucceeds(getDoc(ref));
  });
});
