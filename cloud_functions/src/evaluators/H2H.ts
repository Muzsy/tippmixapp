import { MarketEvaluator, TipInput, NormalizedResult, EvalOutcome } from './MarketEvaluator';

export class H2HEvaluator implements MarketEvaluator {
  key = 'H2H';
  evaluate(tip: TipInput, r: NormalizedResult): EvalOutcome {
    if (!r || !r.completed) return 'pending';
    // Current data model stores selection as team name or 'Draw'.
    const sel = (tip.selection || '').trim();
    const winner = (r.winner || '').trim();
    if (!winner) {
      if (!r.scores) return 'pending';
      const { home, away } = r.scores;
      const computed = home > away ? (r.home_team || 'HOME')
        : away > home ? (r.away_team || 'AWAY')
        : 'Draw';
      return computed === sel ? 'won' : (computed === 'Draw' && sel === 'Draw' ? 'won' : 'lost');
    }
    return winner === sel ? 'won' : 'lost';
  }
}
