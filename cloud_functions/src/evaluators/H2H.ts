import { MarketEvaluator, TipInput, NormalizedResult, EvalOutcome } from './MarketEvaluator';

export class H2HEvaluator implements MarketEvaluator {
  key = 'H2H';
  evaluate(tip: TipInput, r: NormalizedResult): EvalOutcome {
    if (!r || !r.completed) return 'pending';
    // Current data model stores selection as team name or 'Home'/'Away'/'Draw'.
    const norm = (s: string) => (s || '').trim().toLowerCase();
    const sel = norm(tip.selection);

    const homeName = norm(r.home_team || 'home');
    const awayName = norm(r.away_team || 'away');

    // Map selection to a side: 'home' | 'away' | 'draw'
    const selSide = sel === 'draw'
      ? 'draw'
      : (sel === 'home' || sel === homeName)
        ? 'home'
        : (sel === 'away' || sel === awayName)
          ? 'away'
          : sel; // fallback: treat as team name string to compare directly

    // Determine result side from winner/scores
    let resultSide: string | undefined;
    if (r.winner) {
      const w = norm(r.winner);
      resultSide = w === homeName ? 'home' : w === awayName ? 'away' : w === 'draw' ? 'draw' : undefined;
    }
    if (!resultSide) {
      if (!r.scores) return 'pending';
      const { home, away } = r.scores;
      resultSide = home > away ? 'home' : away > home ? 'away' : 'draw';
    }

    if (selSide === 'draw' || resultSide === 'draw') {
      return selSide === resultSide ? 'won' : 'lost';
    }

    // If selection was a team name that isn't equal to home/away side, compare directly to winner name as last resort
    if (selSide !== 'home' && selSide !== 'away') {
      const w = norm(r.winner || (resultSide === 'home' ? homeName : awayName));
      return sel === w ? 'won' : 'lost';
    }

    return selSide === resultSide ? 'won' : 'lost';
  }
}
