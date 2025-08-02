# Sprint 7 – Dupla navigáció (AppBar + BottomNav) javítás

## Kontextus

Jelenleg a `ShellRoute` már körbeveszi az alkalmazást egy `HomeScreen`‑nel (Scaffold + AppBar + BottomNavigationBar), **de** az `AuthGate` is visszaad még egy `HomeScreen`‑t, amint a felhasználó bejelentkezett és megerősítette az e‑mail‑címét. Két Scaffold egymásba ágyazódik, ami **kettős AppBar‑t és alsó menüt** eredményez, és elcsúsztatja a layoutot (például eltakarja a Fogadás FAB‑ot).

## Cél (Goal)

A „/” útvonal betöltésekor **csak egyetlen** AppBar és BottomNavigationBar jelenjen meg.

## Feladatok

- [ ] *auth\_gate.dart* – a bejelentkezett, e‑mail‑ben megerősített ágon **ne** `HomeScreen()`‑t adjon vissza, hanem egy üres widget (pl. `SizedBox.shrink()`), és egy `PostFrameCallback`‑ben navigáljon a default fülre (`/feed`).
- [ ] Töröljük a feleslegessé vált `HomeScreen`‑importot az *auth\_gate.dart*‑ból.
- [ ] Widget‑teszt: a „/” route‑on a widget‑fa **pontosan egy** `AppBar`‑t és **egy** `BottomNavigationBar`‑t tartalmazzon.
- [ ] `flutter analyze` hibamentes.
- [ ] Tesztlefedettség ≥ 80 %.

## Acceptance Criteria / Done Definition

- [ ] A Home képernyőn a dupla navigáció megszűnt.
- [ ] A Fogadás képernyőjén a `FloatingActionButton` nem takarásban van.
- [ ] Minden teszt és elemzés zöld.

## Hivatkozások

- Canvas → `/codex/goals/sprint7_nav_duplication_fix.yaml`
