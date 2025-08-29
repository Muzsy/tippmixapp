import { calcTicketPayout, deriveTicketStatus } from '../src/tickets/payout';

describe('payout calculator', () => {
  test('all won multiplies odds', () => {
    const p = calcTicketPayout(100, [
      { market: '1X2', selection: 'HOME', result: 'won', oddsSnapshot: 1.8 },
      { market: 'OU', selection: 'OVER_2_5', result: 'won', oddsSnapshot: 1.9 },
    ]);
    expect(p).toBeCloseTo(342, 2); // 100 * 1.8 * 1.9
  });
  test('void treated as 1.0', () => {
    const p = calcTicketPayout(100, [
      { market: '1X2', selection: 'HOME', result: 'won', oddsSnapshot: 1.8 },
      { market: 'OU', selection: 'OVER_2_5', result: 'void', oddsSnapshot: 1.9 },
    ]);
    expect(p).toBeCloseTo(180, 2);
  });
  test('lost makes payout 0', () => {
    const p = calcTicketPayout(100, [
      { market: '1X2', selection: 'HOME', result: 'lost', oddsSnapshot: 2.0 },
    ]);
    expect(p).toBe(0);
  });

  test('status: any lost -> lost', () => {
    const tips = [
      { market: '1X2', selection: 'HOME', result: 'lost', oddsSnapshot: 2.0 },
      { market: 'OU', selection: 'OVER_2_5', result: 'void', oddsSnapshot: 1.9 },
    ] as const;
    const payout = calcTicketPayout(100, tips as any);
    expect(deriveTicketStatus(tips as any, payout)).toBe('lost');
  });

  test('status: some won -> won', () => {
    const tips = [
      { market: '1X2', selection: 'HOME', result: 'won', oddsSnapshot: 1.8 },
      { market: 'OU', selection: 'OVER_2_5', result: 'void', oddsSnapshot: 1.9 },
    ] as const;
    const payout = calcTicketPayout(100, tips as any);
    expect(deriveTicketStatus(tips as any, payout)).toBe('won');
  });

  test('status: all void -> void', () => {
    const tips = [
      { market: '1X2', selection: 'HOME', result: 'void', oddsSnapshot: 1.8 },
      { market: 'OU', selection: 'OVER_2_5', result: 'void', oddsSnapshot: 1.9 },
    ] as const;
    const payout = calcTicketPayout(100, tips as any);
    expect(payout).toBeCloseTo(100, 2);
    expect(deriveTicketStatus(tips as any, payout)).toBe('void');
  });
});
