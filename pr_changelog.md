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

## Supabase migration: profiles auto-create + backfill

- Added migration supabase/migrations/202509120015_profiles_trigger_and_backfill.sql
- Creates trigger function public.handle_new_user on auth.users to insert matching profiles row with a generated unique nickname.
- Backfills missing profiles for existing auth.users.
- Verifies local migration with supabase migration up; RLS already configured in 0002_rls_policies.sql.
- Note: flutter test currently has unrelated failures in integration tests (missing fake_cloud_firestore); not part of this change.
