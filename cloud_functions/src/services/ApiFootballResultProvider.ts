// Lightweight API-Football provider
// Node 18+ global fetch; no extra deps required
// v2 alatt ne használj functions.config()-ot; Secret/ENV használata

export interface ScoreResult {
  id: string;
  sport_key: string;
  completed: boolean;
  scores?: { home: number; away: number };
  home_team?: string;
  away_team?: string;
  winner?: string;
  canceled?: boolean;
  status?: string; // raw status short for diagnostics
}

export class ApiFootballResultProvider {
  private readonly baseUrl = 'https://v3.football.api-sports.io';
  private readonly apiKey: string;

  constructor(apiKey: string = process.env.API_FOOTBALL_KEY ?? '') {
    this.apiKey = apiKey;
  }

  /**
   * Fetch scores for given API-Football fixture IDs and map them
   * to the legacy ScoreResult structure used by match_finalizer.
   */
  async getScores(eventIds: string[]): Promise<ScoreResult[]> {
    if (!this.apiKey) {
      throw new Error('Missing API_FOOTBALL_KEY');
    }
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
      // Treat FT/AET/PEN/AWD/WO as completed
      const completedShort = ['FT', 'AET', 'PEN', 'AWD', 'WO'];
      const completed = completedShort.includes(statusShort);
      const canceled = ['CANC', 'ABD'].includes((statusShort || '').toUpperCase());
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
        canceled,
        status: statusShort,
      });
    }
    return results;
  }
}

export async function findFixtureIdByMeta(params: {
  eventName: string | any;
  startTime: string | Date | { toDate?: () => Date } | { seconds?: number } | any;
}): Promise<{ id: number } | null> {
  const [home, away] = (String(params.eventName || '') || '')
    .split(' - ')
    .map((s) => s?.trim())
    .filter(Boolean);
  if (!home || !away) return null;
  let iso: string | undefined;
  const st: any = params.startTime;
  try {
    if (!st) iso = undefined;
    else if (typeof st === 'string') iso = st;
    else if (st instanceof Date) iso = st.toISOString();
    else if (typeof st.toDate === 'function') iso = st.toDate().toISOString();
    else if (typeof st.seconds === 'number') iso = new Date(st.seconds * 1000).toISOString();
  } catch {
    iso = undefined;
  }
  const date = (iso || '').slice(0, 10); // YYYY-MM-DD
  const apiKey = process.env.API_FOOTBALL_KEY ?? '';
  if (!apiKey || !date) return null;

  const base = 'https://v3.football.api-sports.io';
  async function searchByTeam(teamName: string) {
    const url = `${base}/fixtures?date=${encodeURIComponent(
      date,
    )}&search=${encodeURIComponent(teamName)}`;
    const res = await fetch(url, {
      headers: { 'x-rapidapi-key': apiKey, 'x-apisports-key': apiKey },
    });
    if (!res.ok) return [] as any[];
    const json = await res.json().catch(() => null);
    return (json?.response || []) as any[];
  }

  // Keresés mindkét csapatnévre, majd metával pontosítunk
  const [hCand, aCand] = await Promise.all([searchByTeam(home), searchByTeam(away)]);
  const candidates = [...hCand, ...aCand];

  // Pontos egyezés: ugyanaz a nap, egyező home/away (case-insensitive, trim)
  const norm = (s: string) => (s || '').trim().toLowerCase();
  const match = candidates.find((c: any) => {
    const f = c?.fixture;
    const t = c?.teams;
    if (!f || !t) return false;
    const d = (f.date || '').slice(0, 10);
    return (
      d === date &&
      (norm(t.home?.name) === norm(home) || norm(t.home?.name).includes(norm(home))) &&
      (norm(t.away?.name) === norm(away) || norm(t.away?.name).includes(norm(away)))
    );
  });
  if (match?.fixture?.id) return { id: Number(match.fixture.id) };
  return null;
}
