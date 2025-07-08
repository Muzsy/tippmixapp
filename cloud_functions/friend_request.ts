import * as functions from 'firebase-functions';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

export const onFriendRequestAccepted = functions
  .region('europe-central2')
  .firestore.document('relations/{uid}/friendRequests/{requestId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();
    if (!before.accepted && after.accepted) {
      const toUid = after.toUid as string;
      const fromUid = after.fromUid as string;
      await db
        .collection('notifications')
        .doc(toUid)
        .collection('n')
        .add({
          type: 'friend',
          fromUid,
          createdAt: FieldValue.serverTimestamp(),
        });
    }
  });
