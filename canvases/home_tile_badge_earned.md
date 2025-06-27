## 🏅 home\_tile\_badge\_earned.md

### 🎯 Funkció

Ez a csempe azt a legutóbbi badge-et jeleníti meg, amit a felhasználó megszerzett a BadgeSystem által. Célja, hogy az elismerés érzését erősítse, és motiválja a felhasználót a további aktivitásra.

### 🧠 Fejlesztési részletek

* A csempe a BadgeService-ből lekérdezi a legutóbb szerzett badge-et
* Megjelenített elemek:

  * Jelvény ikon (icon\_utils alapján)
  * Badge neve és rövid leírása (lokalizált)
  * CTA (pl. „Összes jelvény megtekintése” → profil képernyő)
* Ha nincs új badge az elmúlt X napban, a csempe nem jelenik meg

### 🧪 Tesztállapot

* Unit teszt: BadgeService lekérdezés logika – időkorlát figyelembevétele
* Widget teszt: csempe megjelenése új badge esetén, ikon és szöveg rendben
* Gomb működésének tesztje (navigáció profilhoz)

### 🌍 Lokalizáció

* Kulcsok:

  * `home_tile_badge_earned_title`: "Új jelvényt szereztél!"
  * `home_tile_badge_earned_cta`: "Összes megtekintése"
* A badge-ek neve és leírása az alábbi struktúra szerint jön:

  * `badge_<kulcs>_title`
  * `badge_<kulcs>_description`
* Lokalizációs fájlok: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* BadgeService → legfrissebb szerzett badge lekérdezése
* icon\_utils → badge ikon leképzése
* Navigation → profil/badge képernyő
* home\_screen.dart → feltételes megjelenítés
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * priority\_rules.md
  * service\_dependencies.md
* Dokumentáció:

  * tippmix\_app\_teljes\_adatmodell.md
  * localization\_best\_practice.md
