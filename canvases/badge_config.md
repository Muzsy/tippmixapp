## 🎯 Funkció

A `badge_config.dart` fájl a TippmixApp alkalmazásban elérhető badge-ek statikus listáját tartalmazza. Ezek alapján a BadgeService értékeli ki, hogy a felhasználó megkapja-e valamelyik jelvényt.

## 🧠 Fejlesztési részletek

* A fájl egy `List<BadgeData>` típusú `badgeConfigs` konstans listát tartalmaz.
* Minden badge az alábbi mezőkkel rendelkezik:

  * `key`: lokalizációs azonosító (pl. `badge_rookie`)
  * `iconName`: a badge ikonja azonosítóként (pl. `star`, `whatshot`)
  * `condition`: badge feltétel, `BadgeCondition` enum alapján

### Tartalmazott badge-ek:

| Kulcs                | Ikon           | Feltétel     |
| -------------------- | -------------- | ------------ |
| badge\_rookie        | star           | firstWin     |
| badge\_hot\_streak   | whatshot       | streak3      |
| badge\_parlay\_pro   | track\_changes | parlayWin    |
| badge\_night\_owl    | nights\_stay   | lateNightWin |
| badge\_comeback\_kid | bolt           | comebackWin  |

## 🧪 Tesztállapot

* A fájl nem tartalmaz logikát, csupán konfigurációt.
* Tesztelhető, hogy minden elem `BadgeData` típusú és enum-kompatibilis.

## 🌍 Lokalizáció

* A badge `key` alapján a megfelelő title/description kulcsokat kell biztosítani az ARB fájlokban.

## 📎 Kapcsolódások

* `badge.dart`: az adatmodell definíciója
* `badge_service.dart`: a logika ezt a listát használja kiértékeléshez
* Kötelező szabályok: `codex_context.yaml`, `localization_logic.md`
* Háttér: `localization_best_practice.md`
