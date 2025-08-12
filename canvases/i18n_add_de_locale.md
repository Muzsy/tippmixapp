# i18n – harmadik nyelv hozzáadása (DE)

## Kontextus

Az odds drift prompt i18n csomag már tartalmaz **EN** és **HU** ARB fájlokat, a projekt háromnyelvű. Feladat a **német (DE)** lokalizáció beemelése azonos kulcsokkal, a `flutter gen-l10n` folyamatba illesztve.

## Cél (Goal)

Új `intl_de.arb` létrehozása a meglévő kulcsok német fordításaival, a lokalizáció generálása és a build validálása.

## Feladatok

* [ ] `lib/l10n/intl_de.arb` létrehozása a meglévő kulcsokkal
* [ ] `flutter gen-l10n` futtatása (AppLocalizations frissül → `supportedLocales` kiegészül **de**‑vel)
* [ ] `flutter analyze` + `flutter test` zöld

## Acceptance Criteria / Done Definition

* [ ] A `lib/l10n/intl_de.arb` létrejött és betöltődik a generáláskor
* [ ] `AppLocalizations.supportedLocales` tartalmazza a `Locale('de')` értéket
* [ ] A dialogban a német szövegek megjelennek (manuális/teszt ellenőrzés)

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_i18n_add_de_locale.yaml`
* Előzmény: `odds_drift_i18n_and_accessibility.md`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

Harmadik nyelv (DE) hozzáadása az i18n‑hez az odds drift prompt (és általános UI) kulcsaira.

### 🧠 Fejlesztési részletek

* ARB hely: `lib/l10n/intl_de.arb`
* Kulcsok: `oddsChangedTitle`, `oddsOld`, `oddsNew`, `accept`, `cancel` (és bővíthető)
* A `flutter gen-l10n` automatikusan felveszi a `de` nyelvet, külön config módosítás nem kell, ha a fájl a mappában van.

### 🧪 Tesztállapot

* Build és teszt zöld; DE megjelenés widget teszttel a következő vászonban kerül lefedésre.

### 🌍 Lokalizáció

* Új nyelv: **de** (német). Fordítások természetes megfogalmazással.

### 📎 Kapcsolódások

* `lib/widgets/odds_drift_dialog.dart` – már lokalizált, automatikusan használja a DE kulcsokat
* Következő vászon: **DE widget teszt** a dialoghoz
