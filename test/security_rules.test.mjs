import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { doc, setDoc, getDoc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { before, after, beforeEach, describe, it } from 'mocha';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'tippmix-test',
    firestore: { rules: readFileSync('firebase.rules', 'utf8') },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('Firestore security rules', () => {
  const authed = (uid) => testEnv.authenticatedContext(uid).firestore();
  const unauthed = () => testEnv.unauthenticatedContext().firestore();

  it('SR-01 coin_logs create saját uid OK', async () => {
    const db = authed('user1');
    await assertSucceeds(setDoc(doc(db, 'coin_logs/log1'), {
      userId: 'user1',
      amount: 50,
      timestamp: serverTimestamp(),
      type: 'bet',
    }));
  });

  it('SR-02 coin_logs create más uid FAIL', async () => {
    const db = authed('user1');
    await assertFails(setDoc(doc(db, 'coin_logs/log2'), {
      userId: 'user2',
      amount: 20,
      timestamp: serverTimestamp(),
      type: 'bet',
    }));
  });

  it('SR-03 coin_logs read saját uid OK', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'coin_logs/id1'), {
      userId: 'user1',
      amount: 10,
      timestamp: serverTimestamp(),
      type: 'deposit',
    });
    const db = authed('user1');
    await assertSucceeds(getDoc(doc(db, 'coin_logs/id1')));
  });

  it('SR-04 coin_logs read más uid FAIL', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'coin_logs/id2'), {
      userId: 'user2',
      amount: 10,
      timestamp: serverTimestamp(),
      type: 'deposit',
    });
    const db = authed('user1');
    await assertFails(getDoc(doc(db, 'coin_logs/id2')));
  });

  it('SR-05 coin_logs update tiltott', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'coin_logs/id3'), {
      userId: 'user1',
      amount: 5,
      timestamp: serverTimestamp(),
      type: 'bet',
    });
    const db = authed('user1');
    await assertFails(updateDoc(doc(db, 'coin_logs/id3'), { amount: 6 }));
  });

  it('SR-06 badge read publikus', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'badges/b1'), { key: 'b1' });
    const db = unauthed();
    await assertSucceeds(getDoc(doc(db, 'badges/b1')));
  });

  it('SR-07 notification read saját', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'notifications/user1/n/n1'), { read: false });
    const db = authed('user1');
    await assertSucceeds(getDoc(doc(db, 'notifications/user1/n/n1')));
  });

  it('SR-08 notification read idegen', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'notifications/user2/n/n1'), { read: false });
    const db = authed('user1');
    await assertFails(getDoc(doc(db, 'notifications/user2/n/n1')));
  });

  it('SR-09 notification markRead saját', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'notifications/user1/n/n1'), { read: false });
    const db = authed('user1');
    await assertSucceeds(updateDoc(doc(db, 'notifications/user1/n/n1'), { read: true }));
  });

  it('SR-10 notification markRead idegen FAIL', async () => {
    const admin = authed('admin');
    await setDoc(doc(admin, 'notifications/user2/n/n2'), { read: false });
    const db = authed('user1');
    await assertFails(updateDoc(doc(db, 'notifications/user2/n/n2'), { read: true }));
  });
});
