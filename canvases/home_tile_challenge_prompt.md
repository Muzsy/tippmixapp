## 🥊 home\_tile\_challenge\_prompt.md

### 🎯 Funkció

Ez a csempe aktív kihívásokra (baráti vagy rendszer által generált napi/heti küldetésekre) hívja fel a figyelmet. Célja a napi aktivitás és közösségi interakció ösztönzése.

### 🧠 Fejlesztési részletek

* A ChallengeService adja vissza az aktív kihívásokat:

  * Pl. barát kihívott egy párbajra
  * Vagy: „Napi kihívás: nyerj 3 fogadást ma!”
* A csempe megjeleníti:

  * Kihívás típusát (baráti / napi / heti)
  * Rövid leírását (lokalizált)
  * Gomb: „Elfogadom”, „Részletek”, vagy „Fogadok most”
* Ha nincs aktív kihívás, a csempe nem jelenik meg

### 🧪 Tesztállapot

* Unit teszt: ChallengeService logika (visszaadja az aktív kihívásokat)
* Widget teszt: többféle kihívás helyes megjelenítése
* Interakció teszt: gomb működés, állapotváltás (elfogadás után új státusz)

### 🌍 Lokalizáció

* Lokalizációs kulcsok:

  * `home_tile_challenge_title`: "Kihívás vár rád!"
  * `home_tile_challenge_daily_description`: "Napi kihívás: nyerj ma 3 fogadást."
  * `home_tile_challenge_friend_description`: "{username} kihívott egy tipppárbajra!"
  * `home_tile_challenge_cta_accept`: "Elfogadom"
* Lokalizáció: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* ChallengeService → aktuális kihívások lekérdezése
* CoinService → jutalom kiosztása (ha teljesítve)
* Navigation → kihívás részletező képernyő vagy új fogadás
* home\_screen.dart → feltételes csempe-megjelenítés
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * priority\_rules.md
  * service\_dependencies.md
* Dokumentáció:

  * tippmix\_app\_teljes\_adatmodell.md
  * localization\_best\_practice.md
