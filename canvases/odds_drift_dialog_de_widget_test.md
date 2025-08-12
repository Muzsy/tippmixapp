# Odds Drift Prompt – DE widget teszt hozzáadása

## Kontextus

Az i18n kiegészült a német (DE) nyelvvel. A dialog már `AppLocalizations`‑t használ. Ehhez hozzáadunk egy célzott widget tesztet, ami a DE locale‑t ellenőrzi.

## Cél (Goal)

Új DE widget teszt, amely felépíti a dialogot `Locale('de')` mellett, és ellenőrzi a cím és a gombfeliratok helyes megjelenését.

## Feladatok

* [ ] Új tesztfájl: `test/widgets/odds_drift_dialog_de_test.dart`
* [ ] Teszt: megjelenik a „Quote geändert” cím, „Abbrechen” és „Akzeptieren” gombok
* [ ] `flutter test` zöld

## Acceptance Criteria / Done Definition

* [ ] A DE widget teszt fut és zöld
* [ ] A feliratok a DE ARB‑ből érkeznek

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_odds_drift_dialog_de_widget_test.yaml`
* Előzmény: `i18n_add_de_locale.md`

---

### 🎯 Funkció

DE lokalizáció widget szintű verifikációja az odds drift dialogon.

### 🧠 Fejlesztési részletek

* A teszt felépít egy `MaterialApp`‑ot DE locale‑lal és meghívja a `showOddsDriftDialog`‑ot.
* Az ellenőrzés szöveg alapú (nincs golden).

### 🧪 Tesztállapot

* `flutter test` zöld, a korábbi EN/HU tesztekkel együtt.

### 🌍 Lokalizáció

* DE feliratok a `lib/l10n/intl_de.arb`‑ból.

### 📎 Kapcsolódások

* `lib/widgets/odds_drift_dialog.dart` – lokalizált dialog
* `test/widgets/odds_drift_dialog_localization_test.dart` – meglévő EN/HU tesztek
