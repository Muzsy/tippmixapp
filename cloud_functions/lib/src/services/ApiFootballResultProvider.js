"use strict";
// Lightweight API-Football provider that mimics the old OddsAPI adapter
// Node 18+ global fetch; no extra deps required
Object.defineProperty(exports, "__esModule", { value: true });
exports.ApiFootballResultProvider = void 0;
class ApiFootballResultProvider {
    constructor(apiKey = process.env.API_FOOTBALL_KEY ?? '') {
        this.baseUrl = 'https://v3.football.api-sports.io';
        if (!apiKey) {
            throw new Error('Missing API_FOOTBALL_KEY');
        }
        this.apiKey = apiKey;
    }
    /**
     * Fetch scores for given API-Football fixture IDs and map them
     * to the legacy ScoreResult structure used by match_finalizer.
     */
    async getScores(eventIds) {
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
            results.push({
                id: String(id),
                sport_key: 'soccer',
                completed: statusShort === 'FT',
                scores: goalsHome !== null && goalsAway !== null
                    ? { home: goalsHome, away: goalsAway }
                    : undefined,
                home_team: item?.teams?.home?.name,
                away_team: item?.teams?.away?.name,
            });
        }
        return results;
    }
}
exports.ApiFootballResultProvider = ApiFootballResultProvider;
