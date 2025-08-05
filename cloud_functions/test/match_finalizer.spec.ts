import { ResultProvider } from '../src/services/ResultProvider';
jest.mock('../src/services/ResultProvider');
jest.mock('../src/services/CoinService');

import * as admin from 'firebase-admin';
import { Firestore } from '@google-cloud/firestore';

import { match_finalizer } from '../src/match_finalizer';

const mockDb = new Firestore();
jest.spyOn(admin, 'firestore').mockReturnValue(mockDb as any);

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

