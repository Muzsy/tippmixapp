/** @jest-environment node */
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { match_finalizer } from '../src/match_finalizer';

// A jest.setup.ts már mockolja az ApiFootballResultProvider-t, ami a
// cloud_functions/mock_apifootball/fixtures_sample.json-t olvassa.

const PROJECT_ID = 'demo-project';
const UID = 'user_e2e';
const TICKET_ID = 'ticket_e2e_1';

// Ezek a fixture ID-k benne vannak a fixtures_sample.json-ben
const FIXTURE_ID_WIN = '123456';   // Home 2-1 Away  → HOME nyer
const FIXTURE_ID_VOID = '223344';  // 0-0 → void/döntetlen

//

const RUN_E2E = process.env.RUN_E2E_EMULATOR === '1';

describe('E2E | create → finalize → payout (idempotens)', () => {
  const envBackup = { ...process.env };

  beforeAll(async () => {
    // Emulátorok
    process.env.GCLOUD_PROJECT = PROJECT_ID;
    process.env.GOOGLE_CLOUD_PROJECT = PROJECT_ID;
    // Bizonyos környezetekben az ADC felülírhatja az emulátort – töröljük a hitelesítési fájl útvonalát
    delete (process.env as any).GOOGLE_APPLICATION_CREDENTIALS;
    process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
    process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';

    // App init → admin.firestore() (idempotens)
    if (getApps().length === 0) {
      initializeApp({ projectId: PROJECT_ID });
    }
    const db = getFirestore();

    // Kezdeti wallet
    await db.collection('users').doc(UID).collection('wallet').doc('main').set({
      coins: 10_000,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Pending ticket két tippel (egy nyerő + egy void)
    await db.collection('users').doc(UID).collection('tickets').doc(TICKET_ID).set({
      status: 'pending',
      stake: 1500,
      createdAt: FieldValue.serverTimestamp(),
      tips: [
        // marketKey: '1X2' az értékelőben 'H2H'-re normalizálódik; outcome szöveges választás
        { eventId: FIXTURE_ID_WIN, marketKey: '1X2', outcome: 'Home', odds: 1.8, result: 'pending' },
        { eventId: FIXTURE_ID_VOID, marketKey: '1X2', outcome: 'Draw', odds: 3.1, result: 'pending' },
      ],
    });
  });

  afterAll(async () => {
    process.env = envBackup;
  });

  (RUN_E2E ? it : it.skip)('finalizes once, credits wallet; second run is idempotent', async () => {
    const db = getFirestore();
    const walletRef = db.collection('users').doc(UID).collection('wallet').doc('main');
    const ticketRef = db.collection('users').doc(UID).collection('tickets').doc(TICKET_ID);

    const before = (await walletRef.get()).data()?.coins ?? 0;

    // 1) Finalizer első futás
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ job: 'final-sweep' })).toString('base64'),
      attributes: { attempt: '0' },
    } as any);

    // Ellenőrzés: ticket státusz/payout
    const t1 = (await ticketRef.get()).data();
    expect(t1).toBeTruthy();
    expect(['won', 'lost', 'void']).toContain(t1!.status);
    // A mock adatokkal a HOME nyer, a másik tipp void → payout > 0
    expect(t1!.payout).toBeGreaterThan(0);

    // Wallet nőtt?
    const mid = (await walletRef.get()).data()?.coins ?? 0;
    expect(mid).toBeGreaterThan(before);

    // 2) Finalizer második futás (idempotencia: ledger refId = ticketId)
    await match_finalizer({
      data: Buffer.from(JSON.stringify({ job: 'final-sweep' })).toString('base64'),
      attributes: { attempt: '1' },
    } as any);

    const after = (await walletRef.get()).data()?.coins ?? 0;
    expect(after).toBe(mid); // nem nő tovább
  });
});
