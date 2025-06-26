## 🎯 Funkció

A Feed képernyő (FeedScreen) integrálása az alkalmazás fő navigációs rendszerébe, beleértve az alsó navigációs sávot (BottomNavigationBar), az oldalsó menüt (Drawer), valamint a GoRouter útvonal-definícióját és a lokalizációs kulcsokat.

## 🧠 Fejlesztési részletek

* **BottomNavigationBar**: Új fülként jelenik meg "Feed" névvel, ikon kíséretében. A felhasználó rákattintva eljut a FeedScreen-re.
* **Drawer (Oldalsó menü)**: Új menüpont "Feed" címmel, amely szintén a FeedScreen-re navigál.
* **GoRouter**: Bővítés egy új útvonallal `/feed` path és `name: 'feed'` paraméterrel. A builder a `FeedScreen`-t adja vissza.
* **Lokalizáció**: A `feed_screen_title`, `drawer_feed`, és `bottom_nav_feed` kulcsok beillesztése az összes támogatott nyelv `.arb` fájljaiba.

## 🧪 Tesztállapot

* `feed_screen_test.dart`: már létezik, ellenőrzi a képernyő renderelését.
* Új tesztek szükségesek:

  * Navigációs teszt (Drawer + BottomNavigationBar interakció)

## 🌍 Lokalizáció

Hiányzó kulcsok:

* `feed_screen_title`: képernyő címsor
* `drawer_feed`: oldalsó menüelem neve
* `bottom_nav_feed`: alsó navigációs fül neve

## 📎 Kapcsolódások

* `lib/screens/feed_screen.dart`
* `lib/widgets/home_feed.dart`
* `lib/widgets/main_scaffold.dart` (vagy ahol a BottomNavigation van definiálva)
* `lib/widgets/app_drawer.dart` (ha van külön fájl a Drawer-höz)
* `lib/router.dart` (vagy hasonló hely a GoRouter konfigurációhoz)
* `lib/l10n/intl_*.arb`
* `test/screens/feed_screen_test.dart`
* Új: `test/navigation/feed_navigation_test.dart`
