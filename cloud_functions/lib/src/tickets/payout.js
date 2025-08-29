"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.calcTicketPayout = calcTicketPayout;
exports.deriveTicketStatus = deriveTicketStatus;
function calcTicketPayout(stake, tips) {
    if (stake <= 0)
        return 0;
    // If any tip is lost, full ticket lost
    if (tips.some(t => t.result === 'lost'))
        return 0;
    // If any tip is pending, no payout yet
    if (tips.some(t => t.result === 'pending'))
        return 0;
    let multiplier = 1.0;
    for (const t of tips) {
        if (t.result === 'void') {
            multiplier *= 1.0; // void refunds stake for that leg
        }
        else if (t.result === 'won') {
            const odds = typeof t.oddsSnapshot === 'number' && t.oddsSnapshot > 0 ? t.oddsSnapshot : 1.0;
            multiplier *= odds;
        }
    }
    const payout = stake * multiplier;
    // Round to 2 decimals for coin representation (adjust if integer coins)
    return Math.round(payout * 100) / 100;
}
function deriveTicketStatus(tips, payout) {
    // Any lost leg -> ticket lost
    if (tips.some(t => t.result === 'lost'))
        return 'lost';
    // If at least one leg is won -> ticket won
    if (tips.some(t => t.result === 'won'))
        return 'won';
    // Otherwise, all legs are void (since pending handled earlier) -> void
    return 'void';
}
