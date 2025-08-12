// Lightweight API-Football provider (prep only) – no wiring yet
// Node 18+ global fetch; no extra deps required

export type ApiFootballScore = {
  eventId: string;
  status: string; // e.g. NS/1H/HT/2H/FT
  homeScore: number | null;
  awayScore: number | null;
  winnerTeamId?: number | null;
  raw?: unknown; // keep raw fragment for future mapping/tests
};

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
   * Fetch scores for given API-Football fixture IDs.
   * NOTE: Kept intentionally generic; match_finalizer wiring comes later.
   */
  async getScores(eventIds: string[]): Promise<ApiFootballScore[]> {
    const headers = { 'x-apisports-key': this.apiKey } as const;
    const results: ApiFootballScore[] = [];

    for (const id of eventIds) {
      const url = `${this.baseUrl}/fixtures?id=${encodeURIComponent(id)}`;
      const res = await fetch(url, { headers });
      if (!res.ok) {
        // Map non-200s to empty/pending for now; detailed handling later
        results.push({ eventId: String(id), status: 'UNK', homeScore: null, awayScore: null });
        continue;
      }
      const json: any = await res.json();
      const item = Array.isArray(json?.response) ? json.response[0] : undefined;
      const statusShort: string = item?.fixtures?.status?.short ?? item?.fixture?.status?.short ?? 'UNK';
      const goalsHome: number | null = item?.goals?.home ?? null;
      const goalsAway: number | null = item?.goals?.away ?? null;
      const winnerId: number | null = item?.teams?.home?.winner ? item?.teams?.home?.id : (item?.teams?.away?.winner ? item?.teams?.away?.id : null);

      results.push({
        eventId: String(id),
        status: statusShort,
        homeScore: goalsHome,
        awayScore: goalsAway,
        winnerTeamId: winnerId,
        raw: item ? {
          status: item?.fixture?.status,
          goals: item?.goals,
          teams: item?.teams,
        } : undefined,
      });
    }
    return results;
  }
}
