# Forum MVP discovery report

## Paths
- Router: `lib/router.dart`
- Bottom navigation: `lib/widgets/my_bottom_navigation_bar.dart`
- Firestore security rules: `firebase.rules`
- Firestore indexes: `firestore.indexes.json`
- Firebase Functions monorepo: `functions/`

## API-Football key handling
- Local development uses `.env` and `env.yaml` with `API_FOOTBALL_KEY`.
- Cloud Functions access it via `process.env.API_FOOTBALL_KEY` or Secret Manager binding.

## Versions
- Flutter SDK: 3.8.1
- App version: 1.4.0+1
