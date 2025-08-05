import * as admin from 'firebase-admin';
import * as fs from 'fs';
import { initializeTestEnvironment, assertSucceeds, RulesTestEnvironment } from '@firebase/rules-unit-testing';
import { ResultProvider } from '../src/services/ResultProvider';

jest.setTimeout(30000); // 30s
jest.mock('../src/services/ResultProvider');

let testEnv: RulesTestEnvironment;
let match_finalizer: (msg: any) => Promise<void>;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'e2e-test',
    firestore: { host: 'localhost', port: 8080, rules: fs.readFileSync('firestore.rules', 'utf8') }
  });

  admin.initializeApp({ projectId: 'e2e-test' } as any);
  (admin.initializeApp as unknown as jest.Mock) = jest.fn();

  (ResultProvider as jest.Mock).mockImplementation(() => {
    return {
      getScores: async () => [{
        id: 'eventMock1', completed: true, sport_key: 'soccer_epl', scores: { home: 2, away: 0 }
      }]
    };
  });

  ({ match_finalizer } = await import('../src/match_finalizer'));
});

afterAll(async () => {
  await testEnv.cleanup();
});

it('happy path – pending ticket becomes won and wallet credited', async () => {
  const db = admin.firestore();
  // Arrange – create pending ticket
  await db.collection('tickets').doc('tick1').set({
    status: 'pending',
    eventId: 'eventMock1',
    potentialProfit: 200,
    uid: 'tester'
  });

  // Act – trigger function
  const msg = { data: Buffer.from(JSON.stringify({ job: 'result-poller' })).toString('base64') } as any;
  await match_finalizer(msg);
  await new Promise(r => setTimeout(r, 100));

  // Assert ticket
  const tSnap = await db.doc('tickets/tick1').get();
  expect(tSnap.get('status')).toBe('won');

  const wSnap = await db.doc('wallets/tester').get();
  expect(wSnap.exists).toBe(true);
  expect(wSnap.get('balance')).toBe(200);
});
