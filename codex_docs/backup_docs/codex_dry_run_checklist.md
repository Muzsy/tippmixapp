# ✅ codex\_dry\_run\_checklist.md – TippmixApp Codex futtatás előtti ellenőrzőlista

Ez a dokumentum egy számonkérhető, lépésről lépésre követhető ellenőrzőlista minden Codex-futtatás előtt. Célja, hogy a generálás konzisztens, hibatűrő és projekt-kompatibilis legyen.

---

## 🧠 Általános elv

Mielőtt bármely `fill_canvas_*.yaml` fájlt átadunk a Codexnek, az alábbi pontokat szigorúan ellenőrizni kell. A cél az, hogy a Codex csak biztos, teljes környezetben kezdjen dolgozni.

---

## ✅ Ellenőrzési lépések

### 1. 🗂️ Fájlszerkezet

- [ ] Létezik a megfelelő canvas fájl: `canvases/<modul>.md`
- [ ] Létezik a YAML utasítás: `codex/goals/fill_canvas_<modul>.yaml`
- [ ] Minden output fájl előre deklarálva van a YAML `outputs:` mezőjében

### 2. 📎 Input és kontextus

- [ ] Minden hivatkozott fájl ténylegesen létezik a projektben
- [ ] A `context` mező tartalmaz lényegi leírást (nem üres)
- [ ] A prompt tartalmazza a canvas kivonatát

### 3. 🔧 Technikai megfelelés

- [ ] Csak a canvas által érintett fájlok módosulnak
- [ ] Nem szerepel `router.dart` módosítás, ha nincs `route:` utasítás
- [ ] Nem keletkezik új service, ha nincs rá külön canvas
- [ ] Lokalizációs kulcs csak akkor jön létre, ha az enum is frissül

### 4. 🧪 Tesztelhetőség

- [ ] Ha új képernyő, tartalmaz widget tesztet
- [ ] Ha új service, tartalmaz unit tesztet
- [ ] Lokalizáció minden nyelvhez szerepel (hu, en, de)

### 5. 🔒 Védelmi szabályok

- [ ] A Codex prompt nem tartalmazhat nem létező útvonalat
- [ ] Nincs "képzeld el" vagy "valószínűleg" típusú szövegezés
- [ ] A prompt végén szerepel: "Add meg a végleges fájl teljes tartalmát."

---

## ⏭️ Javasolt sorrend több canvas esetén

1. `P0` modulok (`coin_service`, `firestore_rules`, `ci_pipeline`, `odds_cache_wrapper`)
2. `P1` modulok (`leaderboard_screen`, `stats_service`, `settings_screen`)
3. `P2` (`badge_service`, `feed_service`, `challenge_service`)
4. `P3` (`ai_recommender`, `tip_reco_widget`)

---

Ez az ellenőrzőlista minden Codex-futtatás kötelező előfeltétele. Bármely pont hiánya esetén a generálás tiltott.
