"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getEvaluator = getEvaluator;
const H2H_1 = require("./H2H");
const registry = {
    H2H: new H2H_1.H2HEvaluator(),
};
function normKey(k) {
    const x = (k || '').trim().toUpperCase();
    if (x === '1X2')
        return 'H2H';
    if (x === 'H2H')
        return 'H2H';
    return x; // future: OU, BTTS, DNB, ...
}
function getEvaluator(marketKey) {
    return registry[normKey(marketKey)];
}
