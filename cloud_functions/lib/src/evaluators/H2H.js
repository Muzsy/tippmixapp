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
        const sel = (tip.selection || '').trim();
        const winner = (r.winner || '').trim();
        if (!winner) {
            if (!r.scores)
                return 'pending';
            const { home, away } = r.scores;
            const computed = home > away ? (r.home_team || 'HOME')
                : away > home ? (r.away_team || 'AWAY')
                    : 'Draw';
            return computed === sel ? 'won' : (computed === 'Draw' && sel === 'Draw' ? 'won' : 'lost');
        }
        return winner === sel ? 'won' : 'lost';
    }
}
exports.H2HEvaluator = H2HEvaluator;
