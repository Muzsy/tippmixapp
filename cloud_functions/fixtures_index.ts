import './global';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './src/lib/firebase';

type TicketData = {
  userId?: string;
  tips?: Array<{
    eventId?: string;
    fixtureId?: number | string;
    result?: 'pending' | 'won' | 'lost' | 'void';
  }>;
};

export async function upsertFixtureIndex(uid: string, ticketId: string, ticket: TicketData) {
  const tips = ticket?.tips ?? [];
  const batch = db.batch();
  tips.forEach((t, idx) => {
    const fid = t?.fixtureId;
    if (!fid && fid !== 0) return;
    const fixtureId = String(fid);
    const status = (t?.result as any) || 'pending';
    const docId = `${ticketId}_${idx}`;
    const ref = db
      .collection('fixtures').doc(fixtureId)
      .collection('ticketTips').doc(docId);
    batch.set(
      ref,
      {
        userId: uid,
        ticketId,
        tipIndex: idx,
        eventId: t?.eventId || null,
        fixtureId,
        status,
        updatedAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
  await batch.commit();
}

export const onTicketWritten_indexFixture = onDocumentWritten(
  'users/{uid}/tickets/{ticketId}',
  async (event) => {
    const uid = event.params.uid as string;
    const ticketId = event.params.ticketId as string;
    const after = event.data?.after?.data() as TicketData | undefined;
    if (!after) return;
    await upsertFixtureIndex(uid, ticketId, after);
  },
);
