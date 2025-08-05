import fs from 'fs';
import path from 'path';

export interface ScoreResult {
  id: string;
  sport_key: string;
  completed: boolean;
  scores?: { home: number; away: number };
}

/**
 * OddsAPI adapter that automatically switches between live HTTP calls (prod)
 * and local JSON mocks (dev/testing).
 */
export class ResultProvider {
  private readonly baseUrl: string;
  private readonly apiKey: string;
  private readonly mode: string;
  private readonly useMock: boolean;

  constructor() {
    this.baseUrl = process.env.ODDS_API_BASE_URL ?? 'https://api.the-odds-api.com/v4';
    this.apiKey = process.env.ODDS_API_KEY ?? '';
    this.mode = process.env.MODE ?? 'prod';
    this.useMock = this.mode === 'dev' && process.env.USE_MOCK_SCORES === 'true';
  }

  /**
   * Fetches scores for the given eventIds. In dev/mock mode returns data from local json.
   */
  async getScores(eventIds: string[]): Promise<ScoreResult[]> {
    if (this.useMock) {
      const mockPath = path.resolve(__dirname, '../../mock_scores/oddsApiSample.json');
      const raw = fs.readFileSync(mockPath, 'utf8');
      return JSON.parse(raw) as ScoreResult[];
    }

    if (!this.apiKey) throw new Error('ODDS_API_KEY missing');

    const chunks: string[][] = [];
    for (let i = 0; i < eventIds.length; i += 40) {
      chunks.push(eventIds.slice(i, i + 40));
    }

    const results: ScoreResult[] = [];

    for (const chunk of chunks) {
      const url = `${this.baseUrl}/sports/scores/?eventIds=${chunk.join(',')}&api_key=${this.apiKey}`;
      const resp = await fetch(url);
      if (!resp.ok) {
        throw new Error(`OddsAPI error ${resp.status}`);
      }
      const json = (await resp.json()) as ScoreResult[];
      results.push(...json);
    }
    return results;
  }
}
