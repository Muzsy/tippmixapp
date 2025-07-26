# 📣 Feed képernyő (FeedScreen)

Ez a vászon leírja a feed funkció önálló képernyős változatát.  A FeedScreen a korábbi `FeedWidget` köré épül, és teljes képernyős megjelenést biztosít a felhasználói tippek, motivációs üzenetek és közösségi tartalmak számára【154869855900165†L0-L10】.

## 🎯 Funkciók

* A feed listázza a legfrissebb eseményeket: tippajánlatokat, közösségi aktivitásokat és motivációs üzeneteket【154869855900165†L6-L9】.
* A képernyő teljes szélességű, nem csak komponensként jelenik meg【154869855900165†L8-L10】.

## 🔧 Technikai követelmények

* Új widget: `FeedScreen` (fájl: `lib/screens/feed_screen.dart`)【154869855900165†L15-L16】.
* Új útvonal: `/feed` (`AppRoute.feed`)【154869855900165†L15-L17】.
* Integráció a `router.dart` fájlba és menübe (Home képernyő drawer + alsó navigációs sáv)【154869855900165†L17-L20】.
* A képernyő tartalma a meglévő `FeedWidget` komponensre épül【154869855900165†L19-L20】.
* A lokalizációs kulcsok ellenőrzése szükséges (`menuFeed`, `home_nav_feed`, `feed_title`)【154869855900165†L32-L39】.

## 🧪 Tesztelés

Új widget tesztet kell írni (pl. `feed_screen_test.dart`), amely ellenőrzi, hogy a feed komponens megjelenik, kezeli az üres állapotot és hiba esetén megfelelő üzenetet jelenít meg【154869855900165†L25-L29】.

## 📎 Modul hivatkozások

- `FeedWidget` – a feed tartalom megjelenítéséért felelős komponens.
- `feed_service.md` – a feed események szolgáltatója【714289051370818†L0-L24】.
- `router.dart`, `HomeScreen` – az útvonal és navigáció integrációja.