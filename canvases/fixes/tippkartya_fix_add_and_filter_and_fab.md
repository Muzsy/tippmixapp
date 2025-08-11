# Tippkártya – tipp hozzáadás + lejárt események szűrése + beküldő FAB bekötése

## Kontextus

A jelenlegi kódállapotban az `EventsScreen` a H2H gombokra **csak SnackBar‑t** mutat, **nem** tesz tippet a szelvénybe, és a listában **lejárt** események is megjelennek. A beküldő képernyő ( `CreateTicketScreen` ) és a route (`/create-ticket`) **létezik**, a FAB logika is be van kötve úgy, hogy **csak akkor látszik**, ha van tipp ( `hasTips` ). Tehát elég az **hozzáadás** és az **időalapú szűrés** javítása.

## Cél (Goal)

1. A H2H gombok megnyomására a kiválasztott kimenetel **hozzáadódjon a szelvényhez** a `betSlipProvider`‑en keresztül.
2. Az eseménylista **szűrje ki** a már kezdődött/lejárt eseményeket (now + 2 perc védőidő).
3. A meglévő FAB (jobb alsó sarok) **továbbra is** csak akkor jelenjen meg, ha van legalább egy tipp, és **/create-ticket**‑re navigáljon.

## Feladatok

* [ ] `lib/screens/events_screen.dart`: a H2H `onTap*` callbackekben **TipModel** összeállítása és `ref.read(betSlipProvider.notifier).addTip(tip)` hívás; SnackBar marad visszajelzésnek (siker/duplikáció).
* [ ] `lib/screens/events_screen.dart`: eseménylista **időalapú szűrése** (import `utils/events_filter.dart`).
* [ ] `lib/utils/events_filter.dart`: `filterActiveEvents(List<OddsEvent>, grace = 2 perc)` util.
* [ ] Tesztek:

  * `test/utils/events_filter_test.dart` – múlt/jövő események helyes szűrése 2p védőidővel.
  * `test/providers/bet_slip_provider_add_tip_test.dart` – `addTip` siker/duplikáció.
* [ ] `flutter analyze` és `flutter test` zöld.

## Acceptance Criteria / Done Definition

* [ ] H2H kattintás → `betSlipProvider.tips.length` **nő** (duplikációnál SnackBar „már a szelvényen van”).
* [ ] Lejárt/azonnal induló (≤ now + 2p) esemény **nem** jelenik meg.
* [ ] FAB **csak** akkor látszik, ha van tipp, és **/create-ticket**‑re navigál.
* [ ] Statikus analízis és tesztek zöldek.

## Hivatkozás

* Canvas → `/canvases/tippkartya_fix_add_and_filter_and_fab.md`
* YAML → `/codex/goals/tippkartya_fix_add_and_filter_and_fab.yaml`

