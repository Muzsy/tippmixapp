# 🧭 Navigáció – Főképernyő vs. Hírfolyam javítás

## 🎯 Funkció

A jelenlegi viselkedés szerint sikeres bejelentkezés és e‑mail ellenőrzés után az alkalmazás **/feed** útvonalra irányít, ezért a **Hírfolyam** jelenik meg „főképernyőként”. A kívánt működés, hogy a bejelentkezett, verifikált felhasználó **a Home (főképernyő) rácsos csempenézetére** érkezzen (útvonal: `/`).

## 🧠 Fejlesztési részletek

**Valós hiba forrása:** `lib/ui/auth/auth_gate.dart` végén fixen van egy átirányítás `/feed`‑re:

```dart
// A ShellRoute már tartalmazza a Home-héjat; itt csak átirányítunk
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (context.mounted) context.go('/feed');
});
return const SizedBox.shrink();
```

**Router szerkezet (releváns):**

* `lib/router.dart`:

  * `initialLocation: '/splash'`
  * A `ShellRoute` a `HomeScreen`‑t adja héjnak.
  * A gyökér `GoRoute(path: '/', name: AppRoute.home, page: NoTransitionPage(child: AuthGate()))` – vagyis **a / útvonal alatt az AuthGate a child**, a héj pedig a `HomeScreen`.
* `lib/screens/home_screen.dart`: ha az aktuális útvonal `'/'`, akkor a `HomeScreen` **a csempés főképernyőt** rendereli (`_isRootRoute(context) == true`).
* `lib/widgets/my_bottom_navigation_bar.dart`: index‑kiosztásnál az **alapértelmezett (egyéb eset)** → index `0` (Home), `/feed` → index `1`.

**Következmény:** az AuthGate jelenlegi „/feed‑re” átirányítása teljesen felülírja a gyökér (`/`) útvonalon megjelenő Home rácsot. Ha **nem irányítunk át**, a `ShellRoute` héj alatt a `'/'` útvonalon a `HomeScreen` a várt főképernyőt fogja mutatni.

**Megoldás:**

* **Eltávolítjuk a `/feed` átirányítást** az `AuthGate`‑ből. Bejelentkezett és verifikált állapotban egyszerűen `SizedBox.shrink()`‑et ad vissza, így a `HomeScreen` (héj) detektálja a `'/'` útvonalat és a főképernyőt jeleníti meg.
* A router egyéb részeihez **nem nyúlunk** (tiltott, illetve felesleges változtatás).
* Teszt: felvesszük a `test/navigation/home_default_route_test.dart` fájlt, ami igazolja, hogy verifikált userrel a kezdő útvonal `/`, és a `HomeScreen` látszik **nem** a `FeedScreen`.

## 🧪 Tesztállapot

* Futtatandó: `flutter analyze`, `flutter test`.
* Új teszt: `home_default_route_test.dart` – ellenőrzi, hogy verifikált felhasználóval a splash → auth‑gate után **nem történik feed‑re irányítás**, hanem a gyökér (`/`) aktív, és a Home UI elemei megjelennek (pl. egy jellegzetes csempe‑widget vagy a stats header).
* Meglévő feed navigációs tesztek (pl. `test/navigation/feed_navigation_test.dart`) **nem sérülnek**, mert továbbra is működik a Feed tab és a drawer navigáció.

## 🌍 Lokalizáció

* Nem kerül új sztring bevezetésre. ARB és l10n generálás **nem szükséges**.

## 📎 Kapcsolódások

* Canvas → `/codex/goals/fix_home_default_route.yaml`
* Érintett fájlok: `lib/ui/auth/auth_gate.dart`, új teszt: `test/navigation/home_default_route_test.dart`

---

# /canvases/fixes/fix\_home\_default\_route.md (vászon)

**Kontextus:** A bejelentkezett, e‑mailben verifikált felhasználókat az `AuthGate` jelenleg a `/feed` útvonalra irányítja, így a Hírfolyam jelenik meg a főképernyő helyett. A projekt router topológiája szerint a `'/'` útvonal alatt a `HomeScreen` (héj) a csempés főnézetet mutatná – ha nem történne átirányítás.

**Cél:** A kezdőképernyő **mindig a Home rács** legyen bejelentkezett, verifikált felhasználóknál (útvonal: `/`).

**Feladatok:**

* [ ] Az `AuthGate` „/feed” átirányításának eltávolítása.
* [ ] Új widget teszt a Home mint alapértelmezett kezdőnézet igazolására.
* [ ] `flutter analyze` és `flutter test` zöld.

**Done/AC:**

* [ ] Nem történik automatikus átirányítás `/feed`‑re verifikált user esetén.
* [ ] A `'/'` útvonal aktív, és a `HomeScreen` főrácsa látszik.
* [ ] Minden meglévő navigációs teszt zöld (Feed tab, Drawer → Feed továbbra is működik).
