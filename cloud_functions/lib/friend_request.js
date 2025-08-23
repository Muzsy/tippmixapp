"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onFriendRequestAccepted = void 0;
require("./global");
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
exports.onFriendRequestAccepted = (0, firestore_1.onDocumentUpdated)('relations/{uid}/friendRequests/{requestId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (before && after && !before.accepted && after.accepted) {
        const toUid = after.toUid;
        const fromUid = after.fromUid;
        await firebase_1.db
            .collection('users')
            .doc(toUid)
            .collection('notifications')
            .doc()
            .set({
            type: 'friend',
            fromUid,
            createdAt: firestore_2.FieldValue.serverTimestamp(),
        });
    }
});
