## 📘 Badge modell

### 🎯 Funkció

A `badge.dart` fájl definiálja a badge rendszer típusait és adatmodelljét.  A badge‑ek gamifikációs célt szolgálnak, és különböző feltételek teljesítésekor járnak a felhasználónak【180772964092141†L0-L3】.

### 🧠 Felépítés

- **`BadgeCondition` enum** – az egyes feltételeket sorolja fel, például:
  * `firstWin` – az első nyertes fogadásért【180772964092141†L8-L13】.
  * `streak3` – három egymást követő nyertes fogadásért【180772964092141†L10-L13】.
  * `parlayWin` – legalább 5 eseményes nyertes kombi szelvényért【180772964092141†L12-L13】.
  * `lateNightWin` – éjfél után nyert szelvényért【180772964092141†L12-L13】.
  * `comebackWin` – 3 vesztes után nyertes szelvényért【180772964092141†L14-L15】.
- **`BadgeData` osztály** – a badge metaadatait tárolja:
  * `key` – lokalizációs azonosító, pl. `badge_rookie`【180772964092141†L17-L20】.
  * `iconName` – a badge‑hez tartozó ikon neve【180772964092141†L18-L19】.
  * `condition` – a badge feltételeinek típusa (enum)【180772964092141†L18-L20】.

### 🧪 Tesztállapot

A `BadgeData` modell egyszerűen tesztelhető inicializálási és enum validációs tesztekkel【180772964092141†L21-L24】.  Mivel nem tartalmaz Flutter‑specifikus típusokat, a tesztek könnyen megírhatók.

### 🌍 Lokalizáció

A `key` mező alapján kell lokalizálni a badge címét és leírását, például `badge_rookie_title` és `badge_rookie_description`【180772964092141†L26-L33】.

### 📎 Kapcsolódások

- `badge_config.md` – a konkrét badge‑ek listáját tartalmazza.
- `badge_service.md` – a badge értékelését és kiosztását végzi【180772964092141†L35-L37】.
- `profile_badge_widget.md` – a badge-ek UI komponense.
- Kötelező szabályok: `codex_context.yaml`, `localization_logic.md`, `priority_rules.md`【180772964092141†L38-L41】.