import { onDocumentCreated, onDocumentDeleted } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import '../lib/firebase';

// Explicit Vote type for trigger payloads
type Vote = {
  postId: string;
  value: number;
};

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

export const onVoteCreate = onDocumentCreated('votes/{voteId}', async (event) => {
  const data = event.data?.data() as unknown as Vote | undefined;
  const postId = data?.postId;
  if (!postId) return;
  await updateCount(postId, 1);
});

export const onVoteDelete = onDocumentDeleted('votes/{voteId}', async (event) => {
  const data = event.data?.data() as unknown as Vote | undefined;
  const postId = data?.postId;
  if (!postId) return;
  await updateCount(postId, -1);
});
