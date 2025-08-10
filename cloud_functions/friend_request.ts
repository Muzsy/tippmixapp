import { setGlobalOptions } from 'firebase-functions/v2/options';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

// Gen 2 – mindenhol europe-central2
setGlobalOptions({ region: 'europe-central2' });

export const onFriendRequestAccepted = onDocumentUpdated(
  'relations/{uid}/friendRequests/{requestId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (before && after && !before.accepted && after.accepted) {
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
