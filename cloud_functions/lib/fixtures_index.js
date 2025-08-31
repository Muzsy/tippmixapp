"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onTicketWritten_indexFixture = void 0;
exports.upsertFixtureIndex = upsertFixtureIndex;
require("./global");
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const firebase_1 = require("./src/lib/firebase");
async function upsertFixtureIndex(uid, ticketId, ticket) {
    const tips = ticket?.tips ?? [];
    const batch = firebase_1.db.batch();
    tips.forEach((t, idx) => {
        const fid = t?.fixtureId;
        if (!fid && fid !== 0)
            return;
        const fixtureId = String(fid);
        const status = t?.result || 'pending';
        const docId = `${ticketId}_${idx}`;
        const ref = firebase_1.db
            .collection('fixtures').doc(fixtureId)
            .collection('ticketTips').doc(docId);
        batch.set(ref, {
            userId: uid,
            ticketId,
            tipIndex: idx,
            eventId: t?.eventId || null,
            fixtureId,
            status,
            updatedAt: firestore_2.FieldValue.serverTimestamp(),
            createdAt: firestore_2.FieldValue.serverTimestamp(),
        }, { merge: true });
    });
    await batch.commit();
}
exports.onTicketWritten_indexFixture = (0, firestore_1.onDocumentWritten)('users/{uid}/tickets/{ticketId}', async (event) => {
    const uid = event.params.uid;
    const ticketId = event.params.ticketId;
    const after = event.data?.after?.data();
    if (!after)
        return;
    await upsertFixtureIndex(uid, ticketId, after);
});
