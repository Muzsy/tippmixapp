## 🏆 home\_tile\_top\_tipster.md

### 🎯 Funkció

Ez a csempe azt a felhasználót jeleníti meg, aki az adott klubban vagy baráti ligában a legjobb tippelési teljesítményt érte el az adott időszakban (napi/heti). Célja a versenyszellem növelése, elismerés és példamutatás.

### 🧠 Fejlesztési részletek

* A KlubService vagy LeaderboardService lekérdezi az aktuális klub/liga top tippelőjét
* A csempe megjeleníti:

  * Felhasználó neve, avatarja
  * Rövid statisztika: pl. „5/5 nyertes tipp ma!”
  * CTA: „Megnézem a tippjeit” → átirányítás a profil vagy feed oldalára
* Ha nincs klub/liga vagy nem elérhető adat, a csempe nem jelenik meg

### 🧪 Tesztállapot

* Unit teszt: klubon belüli top tipster lekérdezés (LeaderboardService)
* Widget teszt: avatar, név és statisztika megjelenik, gomb működik
* Adat hiányában: a csempe nem renderelődik

### 🌍 Lokalizáció

* Lokalizációs kulcsok:

  * `home_tile_top_tipster_title`: "A nap játékosa"
  * `home_tile_top_tipster_description`: "{username} ma 5/5 tippet talált el a klubodban."
  * `home_tile_top_tipster_cta`: "Megnézem a tippjeit"
* Lokalizációs fájlok: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* KlubService / LeaderboardService → top tipster statisztika
* Navigation → felhasználói profil vagy feed (ha elérhető)
* home\_screen.dart → feltételes megjelenítés
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * service\_dependencies.md
* Dokumentáció:

  * tippmix\_app\_teljes\_adatmodell.md
  * localization\_best\_practice.md
