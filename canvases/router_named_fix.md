## 🧭 router.dart – named route fix

### 🎯 Funkció

Ez a vászon a `GoRouter` útvonalakhoz szükséges `name:` mezők pótlására szolgál. A jelenlegi implementációban a `leaderboard` és `settings` képernyők regisztrálva vannak `path:` alapján, de nem rendelkeznek `name:` mezővel. Emiatt a `context.goNamed(...)` hívások futási időben hibát dobnak.

Cél: a `GoRoute` példányok kiegészítése név szerint elérhető útvonallá (`name: AppRoute.xyz.name`), hogy megfeleljenek a `routing_integrity.md` szabálynak.

---

### 🧠 Fejlesztési részletek

* Fájl: `lib/router.dart`
* Jelenleg érintett útvonalak:

  * `/leaderboard` → `LeaderboardScreen()`
  * `/settings` → `SettingsScreen()`
* Jelenlegi forma:

  ```dart
  GoRoute(
    path: '/leaderboard',
    builder: (context, state) => const LeaderboardScreen(),
  ),
  ```
* Helyes forma:

  ```dart
  GoRoute(
    path: '/leaderboard',
    name: AppRoute.leaderboard.name,
    builder: (context, state) => const LeaderboardScreen(),
  ),
  ```

---

### 🧪 Tesztállapot

* 🚫 Jelenleg: futási hiba `unknown route name: leaderboard`
* ✅ Elvárt: `Drawer` menüpont → működő `goNamed()` navigáció
* 🧪 Manuális teszt: Drawer → Ranglista és Beállítások menüpont navigáció

---

### 🌍 Lokalizáció

Nem érintett. A route-nevek nem jelennek meg a UI-ban, nincs lokalizációs hatása.

---

### 📎 Kapcsolódások

* `lib/router.dart` – a módosítandó fájl
* `lib/widgets/app_drawer.dart` – hívásoldali `goNamed()` már rendben van
* `canvases/router_routes_named.md` – tágabb named routing javítási vászon
* `codex_docs/routing_integrity.md` – kötelező named route szabály
