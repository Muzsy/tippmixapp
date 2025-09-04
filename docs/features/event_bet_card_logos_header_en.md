# 🃏 Event Bet Card Logos & Header (EN)

This document describes the addition of optional country/league header and team/league logos on the event bet card.

---

## Summary

- `OddsEvent` model gains optional `countryName`, `leagueName`, `leagueLogoUrl`, `homeLogoUrl` and `awayLogoUrl` fields.
- `ApiFootballService` populates the new fields from fixture responses.
- `TeamBadge` and `LeaguePill` widgets render logos with graceful fallbacks.
- `EventBetCard` header shows `country • league` right-aligned and prepends team badges to names.

## Testing

- Widget tests verify header rendering and TeamBadge fallback.
- `flutter analyze` and `flutter test --concurrency=4` must pass.
- Coverage runs separately (`flutter test --coverage`) in CI or manually.
