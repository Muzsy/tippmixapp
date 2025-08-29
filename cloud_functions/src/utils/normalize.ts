export function normalizeNickname(input: string): string {
  const s = (input || '').trim().toLowerCase();
  // Basic diacritics fold for common HU/DE characters
  const map: Record<string, string> = {
    'á':'a','é':'e','í':'i','ó':'o','ö':'o','ő':'o','ú':'u','ü':'u','ű':'u',
    'ä':'a','ß':'ss'
  };
  const folded = s.replace(/[áéíóöőúüűäß]/g, (m) => map[m] || m);
  return folded.replace(/\s+/g, ' ');
}

