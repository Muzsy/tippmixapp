## 🎯 Funkció

A `badge.dart` fájl célja a badge rendszer típusainak és adatmodelljének definiálása. A badge-ek gamifikációs célt szolgálnak, és különböző feltételek teljesítésekor járnak a felhasználónak.

## 🧠 Fejlesztési részletek

### `badge.dart`

* `BadgeCondition` enum:

  * `firstWin`: az első nyertes fogadásért
  * `streak3`: három egymást követő nyertes fogadásért
  * `parlayWin`: legalább 5 eseményes nyertes kombi szelvényért
  * `lateNightWin`: éjfél után nyert szelvényért
  * `comebackWin`: 3 vesztes után nyertes szelvényért
* `BadgeData` osztály mezői:

  * `key`: azonosító lokalizációhoz, pl. `badge_rookie`
  * `iconName`: a badge-hez tartozó ikon szöveges neve
  * `condition`: a badge feltételeinek típusa (enum)

## 🧪 Tesztállapot

* A `BadgeData` modell tesztelhető inicializálási és enum validációs tesztekkel.
* A fájl nem tartalmaz Flutter-specifikus típusokat, így egyszerűen tesztelhető.

## 🌍 Lokalizáció

* A `key` mező alapján kell lokalizálni:

  * `badge_rookie_title`, `badge_rookie_description`
  * stb., minden badge esetén

## 📎 Kapcsolódások

* `badge_config.dart`: a konkrét badge-ek listáját tartalmazza
* `badge_service.dart`: értékelés és kiosztás
* `profile_badge.dart`: UI megjelenítés
* Kötelező szabályok:

  * `codex_context.yaml`, `localization_logic.md`, `priority_rules.md`
* Háttér: `localization_best_practice.md`, `tippmix_app_teljes_adatmodell.md`
