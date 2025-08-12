import { ApiFootballResultProvider } from "../src/services/ApiFootballResultProvider";

// Mock fetch
const globalAny: any = global;

beforeEach(() => {
  globalAny.fetch = jest.fn(async () => ({
    ok: true,
    json: async () => ({
      response: [{
        fixture: { status: { short: 'FT' } },
        goals: { home: 2, away: 1 },
        teams: {
          home: { id: 10, name: 'Home', winner: true },
          away: { id: 20, name: 'Away', winner: false },
        },
      }],
    })
  }));
  process.env.API_FOOTBALL_KEY = 'test-key';
});

afterEach(() => {
  jest.resetAllMocks();
});

test('parses a basic FT response', async () => {
  const p = new ApiFootballResultProvider();
  const res = await p.getScores(['123']);
  expect(res).toHaveLength(1);
  expect(res[0].completed).toBe(true);
  expect(res[0].scores?.home).toBe(2);
  expect(res[0].scores?.away).toBe(1);
  expect(res[0].home_team).toBe('Home');
  expect(res[0].away_team).toBe('Away');
});
