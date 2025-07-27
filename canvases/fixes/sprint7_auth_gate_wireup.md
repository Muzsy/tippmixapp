# Sprint7 – AuthGate és EmailNotVerifiedScreen bekötése a fő routerbe

## Probléma

A **Sprint 5** során létrehozott `AuthGate`, illetve `EmailNotVerifiedScreen` fájlok fizikailag jelen vannak a kódban, de **egyik route sem használja őket**, ezért e‑mail‑cím megerősítése nélkül is be lehet lépni az alkalmazásba. A Codex CI logban látszik, hogy a fájlok elkészültek, de a `router.dart` nem hivatkozik rájuk.

## Megoldás

1. **Router gyökér‑útvonal (`'/'`)**: a jelenlegi `HomeScreen` helyett egy `AuthGate`-et kell visszaadnia, ami már eldönti, hogy `LoginScreen`, `EmailNotVerifiedScreen` vagy `HomeScreen` jelenjen meg.
2. **Import**: `router.dart` elejére `import 'package:tippmixapp/ui/auth/auth_gate.dart';`
3. **Teszt‑frissítés**: az e‑mail‑verifikációs widget‑tesztek namespace‑e változatlan maradhat, csak a router‐frissítés miatt kell új golden.
4. **Doksi frissítés**: hozzáadjuk, hogy a Home route AuthGate mögött van.

## Acceptance Criteria

* [ ] Nem ellenőrzött fiók `/` navigáció után `EmailNotVerifiedScreen`‑t lát.
* [ ] Ellenőrzött fiók `/` navigáció után `HomeScreen`‑t lát.
* [ ] Anonymous / nem bejelentkezett felhasználó `/` navigáció után `LoginScreen`‑t lát.
* [ ] `flutter analyze` és összes teszt zöld.

---

*Tipp*: a `RegisterStep3Form` már `context.goNamed(AppRoute.home.name)` hívást használ; ez automatikusan az AuthGate‑re fut rá, így nem igényel további módosítást.
