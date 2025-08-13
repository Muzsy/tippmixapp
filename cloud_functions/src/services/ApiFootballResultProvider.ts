// Lightweight API-Football provider
// Node 18+ global fetch; no extra deps required

export interface ScoreResult {
  id: string;
  sport_key: string;
  completed: boolean;
  scores?: { home: number; away: number };
  home_team?: string;
  away_team?: string;
}

export class ApiFootballResultProvider {
  private readonly baseUrl = 'https://v3.football.api-sports.io';
  private readonly apiKey: string;

  constructor(apiKey = process.env.API_FOOTBALL_KEY ?? '') {
    if (!apiKey) {
      throw new Error('Missing API_FOOTBALL_KEY');
    }
    this.apiKey = apiKey;
  }

  /**
   * Fetch scores for given API-Football fixture IDs and map them
   * to the legacy ScoreResult structure used by match_finalizer.
   */
  async getScores(eventIds: string[]): Promise<ScoreResult[]> {
    const headers = { 'x-apisports-key': this.apiKey } as const;
    const results: ScoreResult[] = [];

    for (const id of eventIds) {
      const url = `${this.baseUrl}/fixtures?id=${encodeURIComponent(id)}`;
      const res = await fetch(url, { headers });
      if (!res.ok) {
        // Non-200 → treat as pending
        results.push({ id: String(id), sport_key: 'soccer', completed: false });
        continue;
      }
      const json: any = await res.json();
      const item = Array.isArray(json?.response) ? json.response[0] : undefined;
      const statusShort: string = item?.fixture?.status?.short ?? 'UNK';
      const goalsHome: number | null = item?.goals?.home ?? null;
      const goalsAway: number | null = item?.goals?.away ?? null;
      results.push({
        id: String(id),
        sport_key: 'soccer',
        completed: statusShort === 'FT',
        scores:
          goalsHome !== null && goalsAway !== null
            ? { home: goalsHome, away: goalsAway }
            : undefined,
        home_team: item?.teams?.home?.name,
        away_team: item?.teams?.away?.name,
      });
    }
    return results;
  }
}
