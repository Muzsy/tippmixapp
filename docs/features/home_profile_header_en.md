# 🏠 Home Profile Header (EN)

Introduces a conditional profile header on the Home screen.

## Summary

- Added `GuestCtaTile` prompting anonymous users to sign in or register.
- `HomeScreen` shows `ProfileSummary` when authenticated, otherwise the guest tile.
- Localization keys: `home_guest_title`, `home_guest_subtitle`, `home_guest_login_button`, `home_guest_register_button`.
- Widget tests cover header switching between guest and logged-in states.

## Testing

- `flutter gen-l10n`
- `flutter analyze lib test integration_test bin tool`
- `flutter test`
