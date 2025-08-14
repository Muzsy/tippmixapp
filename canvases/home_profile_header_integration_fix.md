# Home / Főképernyő – Profilfejléc integrációs fix (P0)

## Kontextus

A főképernyő felső részén a profilfejléc (bejelentkezett felhasználónál stat‑összegzés, vendégnél CTA csempe) nem jelenik meg megbízhatóan. A `lib/screens/home_screen.dart` jelenlegi implementációja a teljes tartalmat a `userStatsProvider` aszinkron állapotához köti: `loading` és `error` esetén `SizedBox.shrink()` tér vissza, ezért **üres képernyő** látszik még bejelentkezve is.

Emellett a vendég‑CTA csempe a rácsban (`tiles`) kerül hozzáadásra, miközben az elvárás az, hogy **a fejléc helyén** jelenjen meg.

## Cél

A felső profilfejléc **mindig** renderelődjön a gyökér útvonalon (`/`).

* Bejelentkezett felhasználónál: `UserStatsHeader` jelenjen meg az elérhető statisztikákkal (ha a stat még töltődik, akkor is legyen fejléc – „best effort” adatokkal).
* Vendégnél: a fejléc helyén jelenjen meg a `HomeGuestCtaTile`.
* A csempés rács **mindig** látszódjon, függetlenül a statisztika betöltésétől.
* Ne legyen duplikált vendég‑CTA (ne kerüljön be a rácsba is).

## Feladatok

* [ ] `lib/screens/home_screen.dart` – a `_buildBody` refaktorálása:

  * [ ] A `statsAsync.when(…)` blokk **kiváltása** egy sima `Column` komponensre, amelyben a fejléc külön ágon dönt: bejelentkezett → `UserStatsHeader(stats)`, vendég → `HomeGuestCtaTile`.
  * [ ] A vendég‑CTA csempe **eltávolítása** a `tiles` listából (ne legyen a rácsban is megjelenítve).
  * [ ] A rács összeállítása változatlanul maradjon.
* [ ] Nem vezetünk be új szövegkulcsot (nincs i18n változás).
* [ ] `flutter analyze` és a releváns widget tesztek futtatása (különösen: `test/screens/home_screen_test.dart`).

## Acceptance Criteria / Done Definition

* [ ] Bejelentkezve a főoldalon a fejléc **látszik** (név, coin, win rate), és alatta a csempés rács betölt.
* [ ] Vendégként a fejléc helyén **login/regisztráció CTA** jelenik meg; a rács látható (oktató/daily bonus/egyebek).
* [ ] A képernyő nem üres „loading” állapotban sem; a statisztika későbbi beérkezése frissíti a fejléc adatait.
* [ ] `flutter analyze` hibamentes; `flutter test` zöld (különösen a Home tesztek).

## Hivatkozások

* Érintett fájlok: `lib/screens/home_screen.dart`, `lib/widgets/home/user_stats_header.dart`, `lib/screens/home_guest_cta_tile.dart`
* Canvas → `/codex/goals/home_profile_header_integration_fix.yaml`
* Projekt irányelvek → *Codex Canvas Yaml Guide.pdf*
