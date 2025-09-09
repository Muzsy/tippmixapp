import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

async function updateCount(postId: string, delta: number): Promise<void> {
  const snap = await admin
    .firestore()
    .collectionGroup('posts')
    .where(admin.firestore.FieldPath.documentId(), '==', postId)
    .limit(1)
    .get();
  if (snap.empty) {
    return;
  }
  await snap.docs[0].ref.update({
    votesCount: admin.firestore.FieldValue.increment(delta),
  });
}

export const onVoteCreate = functions.firestore
  .document('votes/{voteId}')
  .onCreate(async (snapshot) => {
    const postId = snapshot.data().entityId as string;
    await updateCount(postId, 1);
  });

export const onVoteDelete = functions.firestore
  .document('votes/{voteId}')
  .onDelete(async (snapshot) => {
    const postId = snapshot.data().entityId as string;
    await updateCount(postId, -1);
  });
