## 💰 home\_tile\_daily\_bonus.md

### 🎯 Funkció

A napi bónuszcsempe célja, hogy motiválja a felhasználókat a mindennapos belépésre és aktivitásra. Megjeleníti, hogy a napi Coin-jutalom elérhető-e, és egyetlen gombnyomással lehetővé teszi annak begyűjtését a CoinService-en keresztül.

### 🧠 Fejlesztési részletek

* A csempe egy egyszerű Card megjelenítés, amely a következő állapotokat kezeli:

  * Elérhető napi bónusz → „Gyűjtsd be a mai bónuszt!” gomb
  * Már begyűjtött bónusz → „Holnap újra jöhetsz” állapot
* A CoinService-től lekérdezi, hogy az adott napon már begyűjtötte-e a user a jutalmat
* A gombnyomás esemény végrehajtja a bónuszjóváírást, és frissíti a státuszt
* Animált ikon vagy konfetti effekttel jelezhető a sikeres begyűjtés (opcionális)

### 🧪 Tesztállapot

* Unit teszt: CoinService napi bónusz függvénye
* Widget teszt: csempe két állapotban (elérhető / begyűjtve)
* UI teszt: gomb megnyomása után a Coin frissül, státusz megváltozik

### 🌍 Lokalizáció

* Szövegkulcsok:

  * `home_tile_daily_bonus_title`: "Napi bónusz!"
  * `home_tile_daily_bonus_button_claim`: "Gyűjtsd be!"
  * `home_tile_daily_bonus_already_claimed`: "Holnap újra jöhetsz."
* Lokalizációs fájlok: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* CoinService → `claimDailyBonus()`, `hasClaimedToday()` metódusok
* Home képernyő → home\_screen\_refactor.dart
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * service\_dependencies.md
* Dokumentáció:

  * tippmix\_app\_teljes\_adatmodell.md
  * localization\_best\_practice.md
