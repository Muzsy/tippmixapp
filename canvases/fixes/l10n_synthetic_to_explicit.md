# 🎯 Funkció

A Flutter gen-l10n lokalizáció **synthetic package** módjáról átállunk **explicit, a repo-ba generált forrásokra** (nincs többé `package:flutter_gen/...`). Cél: hibamentes build az új Flutter beállításokkal (explicit-package-dependencies), egységes `package:tippmixapp/...` importok.

# 🧠 Fejlesztési részletek

**Kiinduló állapot (tippmixapp.zip alapján):**

* `l10n.yaml` jelenleg:

  * `arb-dir: lib/l10n`
  * `template-arb-file: app_en.arb`
  * `output-localization-file: app_localizations.dart`
  * `output-class: AppLocalizations`
  * **`synthetic-package: true`** (→ ez okozza a hibát)
* ARB fájlok: `lib/l10n/app_en.arb`, `app_hu.arb`, `app_de.arb` (3 nyelv)
* Generált források már a repo-ban: `lib/l10n/app_localizations.dart` + nyelvi fájlok
* Importok vegyesek:

  * **\~60 fájl** relatív importtal hivatkozik: `import '../..../l10n/app_localizations.dart';`
  * **\~18 fájl** már `package:tippmixapp/l10n/app_localizations.dart`-ot használ
  * Összesen **82 Dart** fájlban van `AppLocalizations` használat

**Mit csinálunk:**

1. `l10n.yaml` → `synthetic-package: false`, és rögzítjük az `output-dir: lib/l10n` értéket (konzisztens a jelenlegi elhelyezéssel).
2. Minden relatív `app_localizations.dart` importot átalakítunk **`package:tippmixapp/l10n/app_localizations.dart`** formára.
3. Gen-l10n futtatás + statikus ellenőrzés (`flutter analyze`).

**Érintett útvonalak:**

* Konfiguráció: `l10n.yaml`
* Források: minden, ami `AppLocalizations`-t importál.
* Pubspec: `flutter: generate: true` már rendben van, nem módosítjuk.

**Miért így?**

* A synthetic package gyártása ütközik az `explicit-package-dependencies` új alapértelmezésével. Forrásba generálás + `package:` import stabil, IDE-barát, és CI-kompatibilis.

# 🧪 Tesztállapot

* **Build & gen-l10n smoke test:**

  * `flutter clean && flutter pub get && flutter gen-l10n && flutter analyze`
  * Elvárt: 0 analyzer hiba, sikeres generálás.
* **Funkcionális ellenőrzés:**

  * App indul, a fő képernyő lokalizált stringjei megjelennek mindhárom nyelven (HU/EN/DE), váltásnál nincs crash.

# 🌍 Lokalizáció

* Jelenlegi nyelvek: **hu, en, de** (`lib/l10n/app_*.arb`).
* Kimenet: `lib/l10n/app_localizations.dart` + nyelvi implementációk.
* Import standardizálás: `import 'package:tippmixapp/l10n/app_localizations.dart';`

# 📎 Kapcsolódások

* Codex szabályok és guide-ok: `/codex_docs` (különösen: localization\_logic, routing\_integrity, testing\_guidelines, precommit\_checklist)
* Ehhez a vászonhoz tartozó YAML: `/codex/goals/l10n_synthetic_to_explicit.yaml`

---

## ✔️ Done kritériumok

* [ ] `l10n.yaml` → `synthetic-package: false`, `output-dir: lib/l10n`
* [ ] Minden relatív `app_localizations.dart` import → `package:tippmixapp/l10n/app_localizations.dart`
* [ ] `flutter gen-l10n` sikeres, a generált fájlok a repo-ban
* [ ] `flutter analyze` hibamentes
* [ ] App fordul és fut mindhárom nyelven (HU/EN/DE)
