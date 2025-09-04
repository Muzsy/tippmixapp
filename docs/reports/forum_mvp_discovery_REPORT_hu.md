# Fórum MVP feltérképezési jelentés

## Elérési utak
- Router: `lib/router.dart`
- Alsó navigáció: `lib/widgets/my_bottom_navigation_bar.dart`
- Firestore szabályok: `firebase.rules`
- Firestore indexek: `firestore.indexes.json`
- Firebase Functions monorepó: `functions/`

## API-Football kulcs kezelése
- Lokális fejlesztéskor az `API_FOOTBALL_KEY` az `.env` és `env.yaml` fájlokban található.
- A Cloud Functions a `process.env.API_FOOTBALL_KEY` változón vagy Secret Manageren keresztül éri el.

## Verziók
- Flutter SDK: 3.8.1
- Alkalmazás verzió: 1.4.0+1
