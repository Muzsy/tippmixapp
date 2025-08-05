import { ResultProvider } from '../src/services/ResultProvider';

describe('ResultProvider – dev mock', () => {
  process.env.MODE = 'dev';
  process.env.USE_MOCK_SCORES = 'true';

  it('returns mock score array', async () => {
    const provider = new ResultProvider();
    const scores = await provider.getScores(['1234']);
    expect(Array.isArray(scores)).toBe(true);
    expect(scores.length).toBeGreaterThan(0);
    expect(scores[0].completed).toBe(true);
  });
});
