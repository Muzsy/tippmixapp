## Summary
- Remove legacy OddsAPI environment variables and secrets
- Add API_FOOTBALL_KEY references in workflows and env files
- Update Cloud Functions config and jest setup for ApiFootballResultProvider
- Refresh docs for API-Football

## Testing
- `npm ci --prefix cloud_functions` *(fails: ENOTEMPTY)*
- `npm test --prefix cloud_functions` *(fails: jest: not found)*
- `flutter analyze lib test integration_test tool` *(fails: missing dirs)*
- `flutter test` *(interrupted after partial run)*

## Checklist
- [ ] Deploy functions after updating runtime config

## Risks
- Missing API_FOOTBALL_KEY secret will break result fetching

## Rollback
- Reintroduce ODDS_API_KEY env and restore previous workflows
