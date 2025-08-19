# H2H feliratok lokalizálása, ikon-stílus egységesítés, gombsor tipográfia és kiválasztás szinkron

## Kontextus

A H2H gombok jelenleg angol feliratokat ("Home / Draw / Away") jelenítenek meg minden nyelven. Az alsó akciógombok ikonjai vegyes stílusúak, a „További fogadások” gomb felirata nem félkövér, az odds blokk és az akciósor között felesleges divider van. A kiválasztott H2H tipp kiemelése nem szinkronizál a szelvény oldali törléssel / beküldéssel.

## Cél (Goal)

* **Lokalizáció**: H2H gombok feliratai nyelvfüggőek legyenek – HU: „Hazai / Döntetlen / Vendég”.
* **Ikon konzisztencia**: Az alsó három akciógomb (További fogadások / Statisztika / AI tippek) egyforma ikon-stílust használjon.
* **Tipográfia**: „További fogadások” felirat félkövér; divider eltávolítása, helyette kismértékű padding.
* **Kiválasztás jelzése**: H2H gomb kiválasztásakor primer borderrel legyen kiemelve.
* **Szinkron**: A kiválasztás kiemelés törlődjön, ha a tippet a szelvény oldalon törlik, illetve a szelvény beküldése után minden kiemelés alaphelyzetbe álljon.

## Feladatok

* [ ] ARB kulcsok ellenőrzése / pótlása: `home_short`, `draw_short`, `away_short` (HU/EN/DE)
* [ ] `event_bet_card.dart`: H2H feliratok lokalizálása; kiválasztott border; divider → extra padding; alsó főgomb félkövér label; ikonok egységesítése
* [ ] `action_pill.dart`: opcionális `labelStyle` támogatás
* [ ] `ticket_service.dart`: szelvény-események jelzése (tipp törlés, szelvény beküldés) → UI reset hook
* [ ] Widget tesztek / analyze futtatás

## Acceptance Criteria

* [ ] HU/EN/DE locale alatt a H2H feliratok helyesek (Hazai/Draw/Away stb.)
* [ ] A „További fogadások” félkövér, színe változatlan
* [ ] Divider eltűnt; helyette vizuálisan elválaszt a padding
* [ ] Kiválasztott H2H gomb primer borderrel látszik
* [ ] Tipp törlésre / szelvény beküldésre a kártyákon minden kiemelés törlődik
* [ ] `flutter analyze` és `flutter test` zöld

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_h2h_localization_and_selection_sync.yaml`
* Codex Guide → `Codex Canvas Yaml Guide.pdf`
