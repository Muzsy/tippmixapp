### 🆕 Új feladat: Feed képernyő önálló megvalósítása

**Cél:** A Sprint3 során bevezetett `FeedWidget` komponens köré egy teljes értékű, önálló képernyőt készíteni, amely a felhasználói feedet jeleníti meg.

---

### 🎯 Funkciók

* A feed képernyő listázza a tippajánlatokat, motivációs üzeneteket, közösségi tartalmakat.
* Teljes képernyőn jelenik meg (nem csak komponensként).

---

### 🔧 Technikai követelmények

* Új fájl: `lib/screens/feed_screen.dart`
* Új útvonal: `/feed` (ajánlott route: `AppRoute.feed`)
* Integráció a `router.dart` fájlba (GoRouter)
* Új menüpont a `HomeScreen` drawer részébe: `menuFeed`
* Új tab az alsó navigációs sávban (pl. index 3): ikon és címke: `home_nav_feed`
* A képernyő tartalma a meglévő `FeedWidget`
* A `FeedWidget` lokalizációs kulcsait ellenőrizni kell

---

### 🧪 Tesztelés

* Új widget-teszt: `test/screens/feed_screen_test.dart`
* Alap ellenőrzések: feed komponens megjelenik, üres állapot, hibaüzenet

---

### 🌍 Lokalizáció

* Új kulcsok az ARB fájlokba:

  * `menuFeed`: oldalsó menühöz
  * `home_nav_feed`: alsó navigációhoz
  * Cím: `feed_title`

---

### 🔗 Kapcsolatok

* Releváns komponens: `FeedWidget` (Sprint3)
* `AppRoute`, `router.dart`, `HomeScreen`, `AppDrawer`, `BottomNavigationBar` módosítása szükséges

---

### ⏱ Prioritás

* Közepes
* MVP szinten nem kritikus, de fontos kiegészítés a közösségi funkciókhoz

---

### 📝 Megjegyzés

Ez a feladat külön vászonnal és Codex YAML utasítással folytatható, ha a kivitelezés elkezdődik.
