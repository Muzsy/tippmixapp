"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ApiFootballResultProvider = void 0;
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
/**
 * Mock implementation of ApiFootballResultProvider used in tests/dev.
 * Reads static JSON from cloud_functions/mock_apifootball/fixtures_sample.json
 * and returns the same shape as the real provider's getScores().
 */
class ApiFootballResultProvider {
    async getScores(ids) {
        const p = path_1.default.resolve(__dirname, "../../../mock_apifootball/fixtures_sample.json");
        const raw = JSON.parse(fs_1.default.readFileSync(p, "utf8"));
        const map = {};
        for (const f of raw.fixtures)
            map[String(f.fixture.id)] = f;
        const results = [];
        for (const id of ids) {
            const f = map[String(id)];
            if (!f) {
                results.push({ id: String(id), sport_key: "soccer", completed: false });
                continue;
            }
            const goalsHome = f.goals?.home ?? null;
            const goalsAway = f.goals?.away ?? null;
            const statusShort = f.fixture?.status?.short || "FT";
            const completedShort = ['FT', 'AET', 'PEN'];
            const completed = completedShort.includes(statusShort);
            const homeName = f?.teams?.home?.name;
            const awayName = f?.teams?.away?.name;
            const winner = completed && goalsHome !== null && goalsAway !== null
                ? goalsHome > goalsAway
                    ? homeName
                    : goalsAway > goalsHome
                        ? awayName
                        : 'Draw'
                : undefined;
            results.push({
                id: String(id),
                sport_key: "soccer",
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
exports.default = ApiFootballResultProvider;
