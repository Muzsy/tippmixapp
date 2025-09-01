/** @jest-environment node */
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { match_finalizer } from '../src/match_finalizer';

// This test verifies the fixture-index code path: { type: 'finalize', fixtureId }
// It also asserts partial tip update, finalization across multiple fixtures,
// and idempotent wallet credit on the last run.

const PROJECT_ID = 'demo-project';
const UID = 'user_fix_idx';
const TICKET_ID = 'ticket_fix_idx_1';

// Present in mock fixtures: one winning and one draw (void)
const FIXTURE_ID_WIN = '123456';   // Home 2-1 -> won for 'Home'
const FIXTURE_ID_VOID = '223344';  // 0-0 -> void

const RUN_E2E = process.env.RUN_E2E_EMULATOR === '1';

describe('E2E | fixture-index flow', () => {
  const envBackup = { ...process.env };

  beforeAll(async () => {
    process.env.GCLOUD_PROJECT = PROJECT_ID;
    process.env.GOOGLE_CLOUD_PROJECT = PROJECT_ID;
    delete (process.env as any).GOOGLE_APPLICATION_CREDENTIALS;
    process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
    process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';

    if (getApps().length === 0) {
      initializeApp({ projectId: PROJECT_ID });
    }

    const db = getFirestore();

    // Seed wallet
    await db.collection('users').doc(UID).collection('wallet').doc('main').set({
      coins: 10000,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Pending ticket with two tips, both pending initially
    await db.collection('users').doc(UID).collection('tickets').doc(TICKET_ID).set({
      status: 'pending',
      stake: 2000,
      createdAt: FieldValue.serverTimestamp(),
      tips: [
        { eventId: FIXTURE_ID_WIN, marketKey: '1X2', outcome: 'Home', odds: 1.8, result: 'pending' },
        { eventId: FIXTURE_ID_VOID, marketKey: '1X2', outcome: 'Draw', odds: 3.2, result: 'pending' },
      ],
    });

    // Create index entries for both tips
    await db.collection('fixtures').doc(FIXTURE_ID_WIN)
      .collection('ticketTips').doc(`${UID}_${TICKET_ID}_0`).set({
        userId: UID,
        ticketId: TICKET_ID,
        tipIndex: 0,
        status: 'pending',
      });
    await db.collection('fixtures').doc(FIXTURE_ID_VOID)
      .collection('ticketTips').doc(`${UID}_${TICKET_ID}_1`).set({
        userId: UID,
        ticketId: TICKET_ID,
        tipIndex: 1,
        status: 'pending',
      });
  });

  afterAll(async () => {
    process.env = envBackup;
  });

  (RUN_E2E ? it : it.skip)('processes tips per fixture and finalizes when all resolved', async () => {
    const db = getFirestore();
    const ticketRef = db.collection('users').doc(UID).collection('tickets').doc(TICKET_ID);
    const walletRef = db.collection('users').doc(UID).collection('wallet').doc('main');

    const beforeCoins = (await walletRef.get()).data()?.coins ?? 0;

    // 1) Process first fixture (winning leg) via index
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: FIXTURE_ID_WIN })).toString('base64'),
      attributes: { attempt: '0' },
    } as any);

    // After first run: the tip[0].result should be updated, but ticket may still be pending
    const t1 = (await ticketRef.get()).data() as any;
    expect(t1).toBeTruthy();
    expect(t1.tips?.[0]?.result).toBe('won');
    // Not finalized yet because tip[1] is still pending
    expect(t1.status).toBe('pending');

    // Wallet should not be credited yet (payout requires all resolved)
    const midCoins = (await walletRef.get()).data()?.coins ?? 0;
    expect(midCoins).toBe(beforeCoins);

    // 2) Process second fixture (void leg) via index → now all resolved
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: FIXTURE_ID_VOID })).toString('base64'),
      attributes: { attempt: '0' },
    } as any);

    const t2 = (await ticketRef.get()).data() as any;
    // Debug: show tips array for inspection
    // eslint-disable-next-line no-console
    console.log('t2:', JSON.stringify({ status: t2.status, tips: t2.tips }, null, 2));
    expect(['won', 'lost', 'void']).toContain(t2.status);
    expect(t2.processedAt).toBeTruthy();

    const afterCoins = (await walletRef.get()).data()?.coins ?? 0;
    expect(afterCoins).toBeGreaterThan(beforeCoins);

    // 3) Idempotency: re-run should not double-credit
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ type: 'finalize', fixtureId: FIXTURE_ID_VOID })).toString('base64'),
      attributes: { attempt: '1' },
    } as any);

    const after2 = (await walletRef.get()).data()?.coins ?? 0;
    expect(after2).toBe(afterCoins);
  });
});
