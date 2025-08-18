export type EvalOutcome = 'won' | 'lost' | 'void' | 'pending';

export interface NormalizedResult {
  completed: boolean;
  scores?: { home: number; away: number };
  home_team?: string;
  away_team?: string;
  winner?: string; // when available
}

export interface TipInput {
  marketKey: string;          // e.g. 'h2h'
  selection: string;          // current project stores raw outcome string
  odds: number;               // decimal odds snapshot
}

export interface EvaluatedTip {
  market: string;             // normalized market code, e.g. 'H2H'
  selection: string;
  result: EvalOutcome;
  oddsSnapshot: number;
}

export interface MarketEvaluator {
  key: string; // 'H2H', 'OU', 'BTTS', ...
  evaluate(tip: TipInput, result: NormalizedResult): EvalOutcome;
}
