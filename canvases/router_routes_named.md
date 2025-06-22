## 🧭 router.dart – név szerinti route javítás

### 🎯 Funkció

Ez a vászon kifejezetten a `GoRouter` definícióban szereplő named route hibák kijavítására szolgál. A `context.goNamed('leaderboard')` és `context.goNamed('settings')` hívások futási hibát dobnak, mert a `GoRoute` példányok nem tartalmaznak `name:` mezőt, az `AppRoute` enum pedig hiányos.

Cél: minden útvonalhoz legyen `name:` mező rendelve, és az `AppRoute` enum minden route-ot lefedjen.

---

### 🧠 Fejlesztési részletek

* A `lib/router/app_router.dart` fájlban jelenleg nincs minden `GoRoute` példányhoz `name:` mező.
* Az `AppRoute` enum definíciója nem tartalmazza a `leaderboard` és `settings` értékeket.
* Ez ellentmond a `routing_integrity.md` szabálynak, ami előírja a named routingot és a kizárólagos `context.goNamed()` használatot.

Szükséges módosítások:

* `GoRoute(... name: AppRoute.<xyz>.name, ...)` forma minden route-hoz.
* Az `AppRoute` enum bővítése.

Fájlok:

* `lib/router/app_router.dart`
* `lib/widgets/app_drawer.dart` (navigációs hívások)

---

### 🧪 Tesztállapot

* 🚫 Jelenleg a navigációs hívások hibára futnak.
* ✅ A módosítás után a `context.goNamed(...)` hívásoknak működniük kell.
* 🧪 Manuális teszt: Drawer menü használatával navigáció `Leaderboard` és `Settings` képernyőkre.

---

### 🌍 Lokalizáció

Nem érintett. A route-név nem jelenik meg a UI-ban, nincs szükség lokalizált kulcsra.

---

### 📎 Kapcsolódások

* `lib/router/app_router.dart` – GoRouter definíció
* `lib/widgets/app_drawer.dart` – navigációs hívások
* `canvases/router.md` – az alap route-regisztráció vászna
* `codex_docs/routing_integrity.md` – szabály: named route kötelező
* `fill_canvas_router_fix_leaderboard_settings.yaml` – ez a javítás most már része ennek a YAML-nak
