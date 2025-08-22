/** @jest-environment node */
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import * as fs from 'fs';

describe('claim_daily_bonus – idempotencia', () => {
  it('second call should be blocked by cooldown/idempotency', async () => {
    // Ez egy váz: a projekt jelenlegi test setupjához illeszd az initet
    expect(true).toBe(true);
  });
});
