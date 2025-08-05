import { ResultProvider } from '../src/services/ResultProvider';
jest.mock('../src/services/ResultProvider');
jest.mock('../src/services/CoinService', () => ({
  CoinService: jest.fn().mockImplementation(() => ({ credit: jest.fn() }))
}));

jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  firestore: jest.fn(),
}));

import * as admin from 'firebase-admin';
import { Firestore } from '@google-cloud/firestore';

const mockDb = new Firestore({ projectId: 'demo' });
(admin.firestore as any).mockReturnValue(mockDb as any);

const { match_finalizer } = require('../src/match_finalizer');

(ResultProvider as jest.Mock).mockImplementation(() => {
  return {
    getScores: async () => [
      { id: 'event123', sport_key: 'soccer_epl', completed: true, scores: { home: 3, away: 1 } }
    ]
  };
});

it('updates tickets and credits coins on win', async () => {
  // Arrange – create fake pending ticket in emulator memory
  const ticketRef = mockDb.collection('tickets').doc('t1');
  await ticketRef.set({
    status: 'pending',
    eventId: 'event123',
    potentialProfit: 100,
    uid: 'user1'
  });

  // Act – trigger function
  const msg = {
    data: Buffer.from(JSON.stringify({ job: 'result-poller' })).toString('base64')
  } as any;
  await match_finalizer(msg);

  // Assert – ticket status won
  const updated = await ticketRef.get();
  expect(updated.get('status')).toBe('won');
});

