import { MarketEvaluator, TipInput, NormalizedResult } from './MarketEvaluator';
import { H2HEvaluator } from './H2H';

const registry: Record<string, MarketEvaluator> = {
  H2H: new H2HEvaluator(),
};

function normKey(k: string): string {
  const x = (k || '').trim().toUpperCase();
  if (x === '1X2') return 'H2H';
  if (x === 'H2H') return 'H2H';
  return x; // future: OU, BTTS, DNB, ...
}

export function getEvaluator(marketKey: string): MarketEvaluator | undefined {
  return registry[normKey(marketKey)];
}

export type { MarketEvaluator, TipInput, NormalizedResult };
