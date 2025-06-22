## 🧭 router.dart

### 🎯 Funkció

A `router.dart` (pontosabban: `lib/router/app_router.dart`) fájl a GoRouter konfigurációját tartalmazza. A jelenlegi MVP verzióban a `LeaderboardScreen` és a `SettingsScreen` már elkészültek, azonban nem kerültek be a GoRouter útvonalai közé. Ennek következtében a `/leaderboard` és `/settings` navigáció élő alkalmazásban hibára fut (`GoException: no router for location: ...`).

Ez a vászon célja a két route hozzáadása, enum-alapú regisztrációval és `context.goNamed(...)` hívások támogatásával.

---

### 🧠 Fejlesztési részletek

* A GoRouter definíció a `lib/router/app_router.dart` fájlban található.
* Hiányzik a következő két útvonal:

  * `/leaderboard` → `LeaderboardScreen`
  * `/settings` → `SettingsScreen`
* A route-nevek az `AppRoute` enum részeként lesznek definiálva:

  ```dart
  enum AppRoute {
    leaderboard,
    settings,
    // ...
  }
  ```
* A navigáció kizárólag `context.goNamed(AppRoute.leaderboard.name)` formában történhet, a `routing_integrity.md` szabály szerint.

Fő módosítandó fájlok:

* `lib/router/app_router.dart`
* `lib/screens/leaderboard/leaderboard_screen.dart`
* `lib/screens/settings/settings_screen.dart`
* `lib/widgets/app_drawer.dart` (ellenőrzés a navigációs hívásra)

---

### 🧪 Tesztállapot

* 📱 Manuális: a navigáció jelenleg hibára fut, mert nincs route.
* ✅ A módosítás után a Drawer menüből vagy `context.goNamed()` hívásból működni fog a navigáció.
* 🧪 Javasolt widget test: `AppDrawerWidget` → helyes route-hívás ellenőrzése.

---

### 🌍 Lokalizáció

Nem érintett. A `menuLeaderboard` és `menuSettings` kulcsok már szerepelnek az ARB fájlokban (hu/en/de), nem szükséges új kulcs.

---

### 📎 Kapcsolódások

* `lib/router/app_router.dart` – GoRouter definíció
* `lib/screens/leaderboard/leaderboard_screen.dart` – cél widget
* `lib/screens/settings/settings_screen.dart` – cél widget
* `lib/widgets/app_drawer.dart` – navigációs komponens
* `codex_docs/routing_integrity.md` – enum-alapú navigációs szabály
* `fill_canvas_router_fix_leaderboard_settings.yaml` – ehhez tartozó Codex YAML
