import { normalizeNickname } from '../src/utils/normalize';

describe('normalizeNickname', () => {
  it('lowercases and trims', () => {
    expect(normalizeNickname('  Jani  ')).toBe('jani');
  });
  it('collapses spaces', () => {
    expect(normalizeNickname('jan   i')).toBe('jan i');
  });
  it('folds diacritics (HU/DE)', () => {
    expect(normalizeNickname('Árvíztűrő')).toBe('arvizturo');
    expect(normalizeNickname('groß')).toBe('gross');
  });
});

