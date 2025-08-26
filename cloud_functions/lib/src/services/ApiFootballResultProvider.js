"use strict";
// Lightweight API-Football provider
// Node 18+ global fetch; no extra deps required
// v2 environment should avoid v1 firebase-functions config API
Object.defineProperty(exports, "__esModule", { value: true });
exports.ApiFootballResultProvider = void 0;
exports.findFixtureIdByMeta = findFixtureIdByMeta;
class ApiFootballResultProvider {
    constructor(apiKey = process.env.API_FOOTBALL_KEY ?? '') {
        this.baseUrl = 'https://v3.football.api-sports.io';
        this.apiKey = apiKey;
    }
    /**
     * Fetch scores for given API-Football fixture IDs and map them
     * to the legacy ScoreResult structure used by match_finalizer.
     */
    async getScores(eventIds) {
        if (!this.apiKey) {
            throw new Error('Missing API_FOOTBALL_KEY');
        }
        const headers = { 'x-apisports-key': this.apiKey };
        const results = [];
        for (const id of eventIds) {
            const url = `${this.baseUrl}/fixtures?id=${encodeURIComponent(id)}`;
            const res = await fetch(url, { headers });
            if (!res.ok) {
                // Non-200 → treat as pending
                results.push({ id: String(id), sport_key: 'soccer', completed: false });
                continue;
            }
            const json = await res.json();
            const item = Array.isArray(json?.response) ? json.response[0] : undefined;
            const statusShort = item?.fixture?.status?.short ?? 'UNK';
            const goalsHome = item?.goals?.home ?? null;
            const goalsAway = item?.goals?.away ?? null;
            // Treat FT/AET/PEN as completed
            const completedShort = ['FT', 'AET', 'PEN'];
            const completed = completedShort.includes(statusShort);
            const homeName = item?.teams?.home?.name;
            const awayName = item?.teams?.away?.name;
            const winner = completed && goalsHome !== null && goalsAway !== null
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
                scores: goalsHome !== null && goalsAway !== null
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
exports.ApiFootballResultProvider = ApiFootballResultProvider;
async function findFixtureIdByMeta(params) {
    const [home, away] = (params.eventName || '')
        .split(' - ')
        .map((s) => s?.trim())
        .filter(Boolean);
    if (!home || !away)
        return null;
    const date = (params.startTime || '').slice(0, 10); // YYYY-MM-DD
    const apiKey = process.env.API_FOOTBALL_KEY ?? '';
    if (!apiKey || !date)
        return null;
    const base = 'https://v3.football.api-sports.io';
    async function searchByTeam(teamName) {
        const url = `${base}/fixtures?date=${encodeURIComponent(date)}&search=${encodeURIComponent(teamName)}`;
        const res = await fetch(url, {
            headers: { 'x-rapidapi-key': apiKey, 'x-apisports-key': apiKey },
        });
        if (!res.ok)
            return [];
        const json = await res.json().catch(() => null);
        return (json?.response || []);
    }
    // Keresés mindkét csapatnévre, majd metával pontosítunk
    const [hCand, aCand] = await Promise.all([searchByTeam(home), searchByTeam(away)]);
    const candidates = [...hCand, ...aCand];
    // Pontos egyezés: ugyanaz a nap, egyező home/away (case-insensitive, trim)
    const norm = (s) => (s || '').trim().toLowerCase();
    const match = candidates.find((c) => {
        const f = c?.fixture;
        const t = c?.teams;
        if (!f || !t)
            return false;
        const d = (f.date || '').slice(0, 10);
        return (d === date &&
            (norm(t.home?.name) === norm(home) || norm(t.home?.name).includes(norm(home))) &&
            (norm(t.away?.name) === norm(away) || norm(t.away?.name).includes(norm(away))));
    });
    if (match?.fixture?.id)
        return { id: Number(match.fixture.id) };
    return null;
}
