# TippmixApp
![Coverage](./badges/coverage.svg)
[![Coverage Status](https://codecov.io/gh/Muzsy/tippmixapp/branch/main/graph/badge.svg)](https://codecov.io/gh/Muzsy/tippmixapp)
[![Security Rules Coverage](coverage/security_rules_badge.svg)](coverage/security_rules_badge.svg)
[![CI](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml/badge.svg)](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml)

TippmixApp is a minimal Flutter MVP that demonstrates a sports betting workflow.
It integrates Firebase for authentication and data storage, fetches live event
information from the [Odds API](https://the-odds-api.com/), and uses Riverpod for
state management.

## Features

- **Firebase Auth** – email based login and registration.
- **Firestore storage** – tickets and TippCoin balances persisted in the cloud.
- **Odds API integration** – live matches and odds are loaded from the external
  API.
- **Bet slip and ticket creation** – select tips from an event list, then submit
  a ticket.
- **Profile and ticket history** – view account information and your previously
  submitted tickets.
- **GoRouter navigation** and ARB based localization.
- **Riverpod** providers drive reactive UI updates throughout the app.

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) 3.8.1 or
   later.
2. Run `flutter pub get` to fetch dependencies.
3. Create a `.env` file in the project root with your API key:
   ```
   ODDS_API_KEY=YOUR_KEY_HERE
   ```
4. Configure Firebase for each platform (`google-services.json` and
   `GoogleService-Info.plist`). The [FlutterFire](https://firebase.flutter.dev/)
   CLI can generate these files.
5. Launch the application with `flutter run`.
6. Run `flutter test` to execute the small widget tests.

## Repository structure

- `lib/` – application code: screens, widgets, services and providers.
- `docs/` – additional design documents for data models and API integration. Lásd még: `docs/coin_logs_cloud_function.md` a coin naplózás működéséről.
- `test/` – example widget tests.
- `legacy/` – archived files including the deprecated `AppColors` palette.

This MVP focuses on providing a simple end‑to‑end flow using live odds data and
Firebase backend services. Further information about the data models and
architecture can be found in the documentation under `docs/`.

### Theme and colors
The old `AppColors` palette has been moved to `legacy/AppColors.dart` and
is kept only for historical reference. All colors in the active code are
provided through `ThemeBuilder` and `BrandColors` theme extensions.

## CI: Firestore security rules

A GitHub Actions workflow automatikusan futtatja a `scripts/test_firebase_rules.sh` szkriptet minden PR-en es a `main` branchre torteno pushoknal. A szkript elinditja a Firestore Emulatort es lefuttatja a `test/security_rules.test.mjs` tesztjeit. A futas eredmenye a `security_rules_test.log` fajlban elerheto, amely `security-rules-log` artifactkent toltodik fel.

## Avatar Assets

All avatar images must be manually placed in `assets/avatar/`. The default avatar file is `assets/avatar/default_avatar.png` if provided. Do not commit any avatar image files to the repository.
