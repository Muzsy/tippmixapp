"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onFriendRequestAccepted = void 0;
const options_1 = require("firebase-functions/v2/options");
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
// Gen 2 – mindenhol europe-central2
(0, options_1.setGlobalOptions)({ region: 'europe-central2' });
exports.onFriendRequestAccepted = (0, firestore_1.onDocumentUpdated)('relations/{uid}/friendRequests/{requestId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (before && after && !before.accepted && after.accepted) {
        const toUid = after.toUid;
        const fromUid = after.fromUid;
        await firebase_1.db
            .collection('notifications')
            .doc(toUid)
            .collection('n')
            .add({
            type: 'friend',
            fromUid,
            createdAt: firestore_2.FieldValue.serverTimestamp(),
        });
    }
});
