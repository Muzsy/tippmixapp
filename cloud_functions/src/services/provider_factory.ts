import { ApiFootballResultProvider as RealProvider } from './ApiFootballResultProvider';

// Lazy import of mock to avoid bundling when not used
export function createResultProvider() {
  if (process.env.USE_MOCK_SCORES === 'true') {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { ApiFootballResultProvider: MockProvider } = require('./__mocks__/ApiFootballResultProvider');
    return new MockProvider();
  }
  return new RealProvider(process.env.API_FOOTBALL_KEY);
}

