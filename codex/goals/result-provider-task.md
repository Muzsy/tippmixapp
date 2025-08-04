meta:
  canvas: result-provider-task.md
  priority: P1
  after:
    - scheduler-jobs-task.yaml

steps:
  - create_file:
      target: functions/mock_scores/oddsApiSample.json
      content: |
        [
          {
            "id": "1234",
            "sport_key": "soccer_epl",
            "home_team": "Arsenal",
            "away_team": "Chelsea",
            "commence_time": "2025-08-02T15:00:00Z",
            "completed": true,
            "scores": {
              "home": 2,
              "away": 1
            }
          }
        ]

  - create_file:
      target: functions/src/services/ResultProvider.ts
      content: |
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
              const mockPath = path.resolve('functions/mock_scores/oddsApiSample.json');
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

  - create_file:
      target: functions/test/ResultProvider.spec.ts
      content: |
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

  - run: npm install --prefix functions --package-lock-only
  - run: npm test --prefix functions
