import * as admin from 'firebase-admin';
import functionsTest from 'firebase-functions-test';
import { onVoteCreate, onVoteDelete } from '../src/triggers/forumVotes';

const testEnv = functionsTest({ projectId: 'demo-test' });

admin.initializeApp();

describe('forumVotes triggers', () => {
  afterAll(() => {
    testEnv.cleanup();
  });

  it('increments and decrements votesCount', async () => {
    const db = admin.firestore();
    const threadRef = db.collection('threads').doc('t1');
    const postRef = threadRef.collection('posts').doc('p1');
    await threadRef.set({
      title: 't',
      type: 'general',
      createdBy: 'u',
      createdAt: admin.firestore.Timestamp.now(),
      lastActivityAt: admin.firestore.Timestamp.now(),
    });
    await postRef.set({
      threadId: 't1',
      userId: 'u',
      type: 'comment',
      content: 'c',
      createdAt: admin.firestore.Timestamp.now(),
      votesCount: 0,
    });

    const voteSnap = testEnv.firestore.makeDocumentSnapshot(
      {
        entityId: 'p1',
        entityType: 'post',
        userId: 'u2',
        createdAt: admin.firestore.Timestamp.now(),
      },
      'votes/p1_u2'
    );

    const wrappedCreate = testEnv.wrap(onVoteCreate);
    await wrappedCreate(voteSnap);
    let post = await postRef.get();
    expect(post.data()!.votesCount).toBe(1);

    const wrappedDelete = testEnv.wrap(onVoteDelete);
    await wrappedDelete(voteSnap);
    post = await postRef.get();
    expect(post.data()!.votesCount).toBe(0);
  });
});
