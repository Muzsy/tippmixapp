## 🏠 home\_screen\_refactor.md

### 🎯 Funkció

A TippmixApp megújított főképernyője egy dinamikus, csempézett elrendezésű nyitólap, amely a felhasználói aktivitás növelése érdekében statikus lista helyett vizuálisan vonzó, tartalmilag sokszínű és interaktív elemeket jelenít meg. A képernyő célja a statisztikák, gamifikációs elemek, napi bónuszok és AI-alapú ajánlások egyidejű megjelenítése.

### 🧠 Fejlesztési részletek

* A képernyő tetején egy "UserStatsHeader" szekció szerepel, ahol az avatar mellett TippCoin egyenleg, win ratio és ranglista helyezés jelenik meg.
* A fő tartalom egy GridView alapú csempés elrendezés, amely dinamikusan jeleníti meg a napi jutalmat, AI tippeket, legújabb badge-et, feed aktivitást, klub státuszt stb.
* A csempék külön `home_tile_*.dart` fájlokra bonthatók, mindegyik önálló widgetként működik.
* A megjelenített csempék a user állapotától függenek (pl. ha van aktív kihívás, az kihívás csempe jelenik meg).

### 🧪 Tesztállapot

* Widget tesztelés: a `home_screen.dart` új grid layout tesztelése UI snapshot alapján
* Interakció tesztek: napi bónusz gomb működése, AI tipp megnyitása, kihívás elfogadása
* Feltételes renderelés: csempék csak akkor jelennek meg, ha az adott szolgáltatás aktív adatot ad vissza

### 🌍 Lokalizáció

* Minden szöveges tartalom az AppLocalizations kulcsaihoz kötött
* Új kulcsok például:

  * `home_tile_daily_bonus_title`
  * `home_tile_ai_tip_description`
  * `home_tile_top_tipster_button`
* Lokalizáció biztosított: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* CoinService → napi bónusz lekérése, egyenleg megjelenítés
* BadgeService → újonnan szerzett badge-ek
* FeedService → legfrissebb közösségi aktivitások
* AiTipProvider → AI tipp ajánlás
* ChallengeService → baráti kihívások, napi/weekly quest állapot
* KlubService → klubtagság, klubrangsor, klubstatisztika
* Codex szabályfájlok:

  * codex\_docs/codex\_context.yaml
  * codex\_docs/localization\_logic.md
  * codex\_docs/priority\_rules.md
  * codex\_docs/service\_dependencies.md
* Dokumentációk:

  * docs/tippmix\_app\_teljes\_adatmodell.md
  * docs/localization\_best\_practice.md
  * docs/betting\_ticket\_data\_model.md
  * canvases\_odds\_api\_integration.md
