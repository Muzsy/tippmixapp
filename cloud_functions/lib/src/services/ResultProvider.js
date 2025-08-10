"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ResultProvider = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
/**
 * Read ODDS_API_KEY from env; strip quotes and reject unresolved placeholders like "$ODDS_API_KEY".
 */
function readOddsApiKey() {
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
class ResultProvider {
    constructor() {
        this.baseUrl = process.env.ODDS_API_BASE_URL ?? 'https://api.the-odds-api.com/v4';
        this.apiKey = readOddsApiKey();
        this.mode = process.env.MODE ?? 'prod';
        this.useMock = this.mode === 'dev' && process.env.USE_MOCK_SCORES === 'true';
    }
    /**
     * Fetches scores for the given eventIds. In dev/mock mode returns data from local json.
     */
    async getScores(eventIds) {
        if (this.useMock) {
            const mockPath = path_1.default.resolve(__dirname, '../../mock_scores/oddsApiSample.json');
            const raw = fs_1.default.readFileSync(mockPath, 'utf8');
            return JSON.parse(raw);
        }
        const chunks = [];
        for (let i = 0; i < eventIds.length; i += 40) {
            chunks.push(eventIds.slice(i, i + 40));
        }
        const results = [];
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
            const url = `${this.baseUrl}/sports/${sport}/scores/?daysFrom=3`;
            const resp = await fetch(url, { headers: { 'x-api-key': this.apiKey } });
            if (!resp.ok) {
                // 404 előfordulhat nem támogatott sport kulcsnál – lépjünk tovább a többire
                if (resp.status === 404)
                    continue;
                throw new Error(`OddsAPI error ${resp.status}`);
            }
            const json = (await resp.json());
            for (const item of json) {
                if (wanted.has(item.id)) {
                    results.push(item);
                }
            }
        }
        return results;
    }
}
exports.ResultProvider = ResultProvider;
