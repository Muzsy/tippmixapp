"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const ResultProvider_1 = require("../src/services/ResultProvider");
describe('ResultProvider – dev mock', () => {
    process.env.MODE = 'dev';
    process.env.USE_MOCK_SCORES = 'true';
    it('returns mock score array', async () => {
        const provider = new ResultProvider_1.ResultProvider();
        const scores = await provider.getScores(['1234']);
        expect(Array.isArray(scores)).toBe(true);
        expect(scores.length).toBeGreaterThan(0);
        expect(scores[0].completed).toBe(true);
    });
});
