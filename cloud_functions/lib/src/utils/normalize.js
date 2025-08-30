"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeNickname = normalizeNickname;
function normalizeNickname(input) {
    const s = (input || '').trim().toLowerCase();
    // Basic diacritics fold for common HU/DE characters
    const map = {
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ö': 'o', 'ő': 'o', 'ú': 'u', 'ü': 'u', 'ű': 'u',
        'ä': 'a', 'ß': 'ss'
    };
    const folded = s.replace(/[áéíóöőúüűäß]/g, (m) => map[m] || m);
    return folded.replace(/\s+/g, ' ');
}
