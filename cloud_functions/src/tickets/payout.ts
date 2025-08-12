export type Tip = {
  market: string;           // e.g. '1X2' | 'OU' | 'BTTS' | 'AH'
  selection: string;        // e.g. 'HOME' | 'DRAW' | 'AWAY' | 'OVER_2_5' | ...
  result: 'won' | 'lost' | 'void' | 'pending';
  oddsSnapshot: number;     // required for won/void; ignored when lost=0
};

export function calcTicketPayout(stake: number, tips: Tip[]): number {
  if (stake <= 0) return 0;
  // If any tip is lost, full ticket lost
  if (tips.some(t => t.result === 'lost')) return 0;
  // If any tip is pending, no payout yet
  if (tips.some(t => t.result === 'pending')) return 0;
  let multiplier = 1.0;
  for (const t of tips) {
    if (t.result === 'void') {
      multiplier *= 1.0; // void refunds stake for that leg
    } else if (t.result === 'won') {
      const odds = typeof t.oddsSnapshot === 'number' && t.oddsSnapshot > 0 ? t.oddsSnapshot : 1.0;
      multiplier *= odds;
    }
  }
  const payout = stake * multiplier;
  // Round to 2 decimals for coin representation (adjust if integer coins)
  return Math.round(payout * 100) / 100;
}
