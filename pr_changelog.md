# PR Changelog

## Lint and Fix
- `dart fix --apply` failed due to missing `dart` command.

## DebugPrint cleanup
- Removed `debugPrint` and `debugPrintStack` calls from:
  - `lib/services/coin_service.dart`
  - `lib/services/odds_api_service.dart`
  - `lib/services/bet_slip_service.dart`
  - `lib/providers/odds_api_provider.dart`

## Golden tests
- No skipped golden tests found; no updates required.

## TODO report
- See `todo_report.txt` for remaining TODO comments.

## Register debug fix
- Added debug log in `AuthService.registerWithEmail`.
- Created widget and integration tests for registration flow.
