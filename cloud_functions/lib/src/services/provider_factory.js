"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createResultProvider = createResultProvider;
const ApiFootballResultProvider_1 = require("./ApiFootballResultProvider");
// Lazy import of mock to avoid bundling when not used
function createResultProvider() {
    if (process.env.USE_MOCK_SCORES === 'true') {
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        const { ApiFootballResultProvider: MockProvider } = require('./__mocks__/ApiFootballResultProvider');
        return new MockProvider();
    }
    return new ApiFootballResultProvider_1.ApiFootballResultProvider(process.env.API_FOOTBALL_KEY);
}
