## 📣 home\_tile\_feed\_activity.md

### 🎯 Funkció

Ez a csempe a TippmixApp FeedService moduljából származó friss közösségi aktivitásokat jeleníti meg. Célja, hogy a felhasználó lássa, mit osztanak meg mások, és közvetlenül rákattinthasson ezekre az eseményekre.

### 🧠 Fejlesztési részletek

* A FeedService-ből lekérdezhető legfrissebb esemény:

  * Pl. „Pisti95 megosztott egy 5/5-ös kombit”
  * „Anna12 tippje 38x oddsszal nyert!”
* A csempe tartalmazza:

  * Felhasználó nevét + avatart
  * Rövid leírását a feed eseménynek
  * Gomb: „Megnézem” → navigálás a teljes feed vagy a konkrét poszt oldalára
* Ha nincs elérhető új esemény, a csempe nem jelenik meg

### 🧪 Tesztállapot

* Unit teszt: FeedService lekérdezés működik, legfrissebb esemény visszatér
* Widget teszt: avatar, szöveg, gomb megjelenik
* Navigációs teszt: gombra kattintás a megfelelő oldalra visz

### 🌍 Lokalizáció

* Lokalizációs kulcsok:

  * `home_tile_feed_activity_title`: "Legújabb aktivitás"
  * `home_tile_feed_activity_text_template`: "{username} megosztott egy nyertes tippet!"
  * `home_tile_feed_activity_cta`: "Megnézem"
* Lokalizációs fájlok: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* FeedService → feed események lekérdezése (pl. public\_feed kollekció)
* Navigation → home\_feed vagy konkrét feed poszt megnyitása
* home\_screen.dart → feltételes megjelenítés
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * routing\_integrity.md
* Dokumentáció:

  * tippmix\_app\_teljes\_adatmodell.md
  * localization\_best\_practice.md
