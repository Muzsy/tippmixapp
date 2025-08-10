import fs from 'fs';
import path from 'path';

export interface ScoreResult {
  id: string;
  sport_key: string;
  completed: boolean;
  scores?: { home: number; away: number };
  home_team?: string;
  away_team?: string;
}

/**
 * Read ODDS_API_KEY from env; strip quotes and reject unresolved placeholders like "$ODDS_API_KEY".
 */
function readOddsApiKey(): string {
  const raw = (process.env.ODDS_API_KEY ?? '').trim();
  const cleaned = raw.replace(/^['"]|['"]$/g, '');
  // If value looks like an unresolved shell placeholder (e.g. "$ODDS_API_KEY"), treat as missing
  if (!cleaned || /^\$[A-Z0-9_]+$/.test(cleaned)) {
    throw new Error('Config error: ODDS_API_KEY is missing or is an unresolved placeholder');
  }
  return cleaned;
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
    this.apiKey = readOddsApiKey();
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

    const chunks: string[][] = [];
    for (let i = 0; i < eventIds.length; i += 40) {
      chunks.push(eventIds.slice(i, i + 40));
    }

    const results: ScoreResult[] = [];
    // A The Odds API v4 scores végpont sportonként érhető el.
    // A ticket dokumentumok nem tartalmaznak sport kulcsot, ezért az engedélyezett
    // sportok (ALLOWED_SPORTS) alapján lehúzzuk az elmúlt 3 nap eredményeit
    // és helyben szűrünk az eventIds szerint.
    const allowed = (process.env.ALLOWED_SPORTS || '')
      .split(',')
      .map(s => s.trim())
      .filter(Boolean);
    const sports = allowed.length ? allowed : ['soccer_epl', 'basketball_nba'];

    const wanted = new Set(eventIds);

    for (const sport of sports) {
      // A v4 API autentikáció néhány régión 2025-ben csak query paraméterrel sikerül (401-es válasz jöhet a csak headeres hívásra),
      // ezért redundánsan HEADERS + QUERY módon adjuk át a kulcsot.
      const u = new URL(`${this.baseUrl}/sports/${sport}/scores/`);
      u.search = new URLSearchParams({ daysFrom: '3', apiKey: this.apiKey }).toString();
      const resp = await fetch(u.toString(), { headers: { 'x-api-key': this.apiKey } });
      if (!resp.ok) {
        // 404 előfordulhat nem támogatott sport kulcsnál – lépjünk tovább a többire
        if (resp.status === 404) continue;
        throw new Error(`OddsAPI error ${resp.status}`);
      }
      const json = (await resp.json()) as ScoreResult[];
      for (const item of json) {
        if (wanted.has(item.id)) {
          results.push(item);
        }
      }
    }
    return results;
  }
}
