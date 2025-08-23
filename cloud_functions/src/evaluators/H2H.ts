import { MarketEvaluator, TipInput, NormalizedResult, EvalOutcome } from './MarketEvaluator';

export class H2HEvaluator implements MarketEvaluator {
  key = 'H2H';
  evaluate(tip: TipInput, r: NormalizedResult): EvalOutcome {
    if (!r || !r.completed) return 'pending';
    // Current data model stores selection as team name or 'Draw'.
    const norm = (s: string) => (s || '').trim().toLowerCase();
    const sel = norm(tip.selection);
    const winner = norm(r.winner || '');
    if (!winner) {
      if (!r.scores) return 'pending';
      const { home, away } = r.scores;
      const compRaw = home > away ? (r.home_team || 'home')
        : away > home ? (r.away_team || 'away')
        : 'draw';
      const computed = norm(compRaw);
      if (computed === 'draw' && sel === 'draw') return 'won';
      return computed === sel ? 'won' : 'lost';
    }
    return winner === sel ? 'won' : 'lost';
  }
}
