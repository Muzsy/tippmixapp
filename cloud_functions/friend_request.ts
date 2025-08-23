import './global';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

export const onFriendRequestAccepted = onDocumentUpdated(
  'relations/{uid}/friendRequests/{requestId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (before && after && !before.accepted && after.accepted) {
      const toUid = after.toUid as string;
      const fromUid = after.fromUid as string;
      await db
        .collection('users')
        .doc(toUid)
        .collection('notifications')
        .doc()
        .set({
          type: 'friend',
          fromUid,
          createdAt: FieldValue.serverTimestamp(),
        });
    }
  });
