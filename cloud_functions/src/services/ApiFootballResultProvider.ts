// Lightweight API-Football provider
// Node 18+ global fetch; no extra deps required

export interface ScoreResult {
  id: string;
  sport_key: string;
  completed: boolean;
  scores?: { home: number; away: number };
  home_team?: string;
  away_team?: string;
  winner?: string;
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
      // Treat FT/AET/PEN as completed
      const completedShort = ['FT', 'AET', 'PEN'];
      const completed = completedShort.includes(statusShort);
      const homeName = item?.teams?.home?.name;
      const awayName = item?.teams?.away?.name;
      const winner =
        completed && goalsHome !== null && goalsAway !== null
          ? goalsHome > goalsAway
            ? homeName
            : goalsAway > goalsHome
              ? awayName
              : 'Draw'
          : undefined;
      results.push({
        id: String(id),
        sport_key: 'soccer',
        completed,
        scores:
          goalsHome !== null && goalsAway !== null
            ? { home: goalsHome, away: goalsAway }
            : undefined,
        home_team: homeName,
        away_team: awayName,
        winner,
      });
    }
    return results;
  }
}

export async function findFixtureIdByMeta(params: { eventName: string; startTime: string }): Promise<{ id: number } | null> {
  const [home, away] = params.eventName.split(' - ').map(s => s?.trim()).filter(Boolean);
  if (!home || !away) return null;
  const date = params.startTime.slice(0, 10); // YYYY-MM-DD
  // Példa: GET /fixtures?date=YYYY-MM-DD&team=... (vagy search endpoint a bevezetett logika szerint)
  // Itt a projekt meglévő fetch utilját használjuk, és a válaszból a (home,away,start) egyezést keressük.
  // A pontos implementáció a szolgáltató végpontjaihoz igazodik.
  return null; // helykitöltő: a tényleges végpont-hívás a projekt utils szerint kerül megírásra
}
