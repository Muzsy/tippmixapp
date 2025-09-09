/** @jest-environment node */
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';

let testEnv: any;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'forum-rules-test',
    firestore: { rules: readFileSync('../firebase.rules', 'utf8') },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe('forum rules', () => {
  it('requires auth to create thread', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      db.collection('threads').add({
        title: 't',
        type: 'general',
        createdBy: 'u1',
        createdAt: 0,
        pinned: false,
        locked: false,
        fixtureId: null,
        lastActivityAt: 0,
      })
    );
  });

  it('blocks post creation in locked thread', async () => {
    const user = testEnv.authenticatedContext('u1');
    const db = user.firestore();
    const threadRef = db.collection('threads').doc('t1');
    await assertSucceeds(
      threadRef.set({
        title: 't',
        type: 'general',
        createdBy: 'u1',
        createdAt: 0,
        pinned: false,
        locked: true,
        fixtureId: null,
        lastActivityAt: 0,
      })
    );
    await assertFails(
      threadRef.collection('posts').add({
        id: 'p1',
        threadId: 't1',
        userId: 'u1',
        type: 'comment',
        content: 'hi',
        createdAt: 0,
      })
    );
  });

  it('only moderator may delete post', async () => {
    const user = testEnv.authenticatedContext('u1');
    const db = user.firestore();
    const threadRef = db.collection('threads').doc('t2');
    await threadRef.set({
      title: 't',
      type: 'general',
      createdBy: 'u1',
      createdAt: 0,
      pinned: false,
      locked: false,
      fixtureId: null,
      lastActivityAt: 0,
    });
    const postRef = threadRef.collection('posts').doc('p1');
    await postRef.set({
      threadId: 't2',
      userId: 'u1',
      type: 'comment',
      content: 'hi',
      createdAt: 0,
    });
    await assertFails(postRef.delete());

    const mod = testEnv.authenticatedContext('m1', {
      roles: { moderator: true },
    });
    const modDb = mod.firestore();
    await assertSucceeds(
      modDb.collection('threads').doc('t2').collection('posts').doc('p1').delete(),
    );
  });

  it('requires auth to create report', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      db.collection('reports').add({
        reporterId: 'u1',
        entityType: 'post',
        entityId: 'p1',
        reason: 'spam',
        createdAt: 0,
      }),
    );
  });
});
