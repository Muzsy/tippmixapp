const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

exports.onFriendRequestAccepted = functions
  .region('europe-central2')
  .firestore.document('relations/{uid}/friendRequests/{requestId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();
    if (!before.accepted && after.accepted) {
      const toUid = after.toUid;
      const fromUid = after.fromUid;
      await db
        .collection('notifications')
        .doc(toUid)
        .collection('n')
        .add({
          type: 'friend',
          fromUid,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
  });
