"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.H2HEvaluator = void 0;
class H2HEvaluator {
    constructor() {
        this.key = 'H2H';
    }
    evaluate(tip, r) {
        if (!r || !r.completed)
            return 'pending';
        // Current data model stores selection as team name or 'Draw'.
        const norm = (s) => (s || '').trim().toLowerCase();
        const sel = norm(tip.selection);
        const winner = norm(r.winner || '');
        if (!winner) {
            if (!r.scores)
                return 'pending';
            const { home, away } = r.scores;
            const compRaw = home > away ? (r.home_team || 'home')
                : away > home ? (r.away_team || 'away')
                    : 'draw';
            const computed = norm(compRaw);
            if (computed === 'draw' && sel === 'draw')
                return 'won';
            return computed === sel ? 'won' : 'lost';
        }
        return winner === sel ? 'won' : 'lost';
    }
}
exports.H2HEvaluator = H2HEvaluator;
