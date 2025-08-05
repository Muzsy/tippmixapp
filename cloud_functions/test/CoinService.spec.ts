import * as admin from 'firebase-admin';
import { Firestore } from '@google-cloud/firestore';

admin.initializeApp({ projectId: 'demo' } as any);
const mockDb = new Firestore({ projectId: 'demo' });
jest.spyOn(admin, 'firestore').mockReturnValue(mockDb as any);

const { CoinService } = require('../src/services/CoinService');

describe('CoinService transact', () => {
  afterAll(async () => {
    await mockDb.terminate();
  });

  it('credits only once on concurrent calls', async () => {
    const svc = new CoinService();

    await Promise.all([
      svc.credit('u1', 50, 'ticket42'),
      svc.credit('u1', 50, 'ticket42')
    ]);

    const walletSnap = await mockDb.doc('wallets/u1').get();
    expect(walletSnap.get('balance')).toBe(50);

    const ledgerSnap = await mockDb.doc('wallets/u1/ledger/ticket42').get();
    expect(ledgerSnap.exists).toBe(true);
  });
});
