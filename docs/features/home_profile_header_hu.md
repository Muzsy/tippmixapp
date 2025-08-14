# 🏠 Főképernyő profil fejléc (HU)

Leírja a feltételes profilfejlécet a főképernyőn.

## Összefoglaló

- Új `GuestCtaTile` csempe vendégeknek bejelentkezés/regisztráció gombokkal.
- A `HomeScreen` bejelentkezett felhasználónál `ProfileSummary`-t, vendégnél a csempét jelenít meg.
- Lokalizációs kulcsok: `home_guest_title`, `home_guest_subtitle`, `home_guest_login_button`, `home_guest_register_button`.
- Widget tesztek biztosítják a fejlécek váltását.

## Tesztelés

- `flutter gen-l10n`
- `flutter analyze lib test integration_test bin tool`
- `flutter test`
