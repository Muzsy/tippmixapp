## 🤖 home\_tile\_ai\_tip.md

### 🎯 Funkció

Ez a csempe az AI-alapú Tippelő modul által javasolt legvalószínűbb napi tippet jeleníti meg a főképernyőn. Célja, hogy irányt mutasson a kevésbé tapasztalt felhasználóknak, növelje a bizalmat, és interaktívabbá tegye a fogadást.

### 🧠 Fejlesztési részletek

* A csempe egy AI által generált tippet jelenít meg egy mondatos formában, pl.:

  * „AI szerint ma a Bayern győzelme a legvalószínűbb (78%).”
* A háttérben az AiTipProvider szolgáltatás adja az adatot, amely figyelembe veszi a csapatformát, statisztikákat, odds-mozgást stb.
* A csempe gombot is tartalmazhat: „Részletek megtekintése” → AI ajánló oldal
* Ha nincs elérhető AI tipp, a csempe nem jelenik meg

### 🧪 Tesztállapot

* Unit teszt: AiTipProvider logika helyessége (pl. max. 1 napi ajánlás)
* Widget teszt: a csempe csak akkor renderelődik, ha van tipp
* Interakció: részletek gombra navigáció működése

### 🌍 Lokalizáció

* Kulcsok:

  * `home_tile_ai_tip_title`: "AI ajánlás"
  * `home_tile_ai_tip_description`: "AI szerint ma a {team} győzelme a legvalószínűbb ({percent}%)."
  * `home_tile_ai_tip_cta`: "Részletek megtekintése"
* Lokalizáció mindhárom nyelvre: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* AiTipProvider → napi tipp lekérdezése
* Navigation → AI Tipp részletező képernyő (opcionális, csak ha már létezik)
* home\_screen.dart → feltételes megjelenítés
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * priority\_rules.md
  * service\_dependencies.md
* Dokumentáció:

  * tippmix\_app\_teljes\_adatmodell.md
  * localization\_best\_practice.md
