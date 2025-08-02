## 💰 Napi bónusz csempe modul

### 🎯 Funkció

A napi bónuszcsempe célja, hogy motiválja a felhasználókat a mindennapos belépésre és aktivitásra.  Megjeleníti, hogy a napi Coin‑jutalom elérhető‑e, és egyetlen gombnyomással lehetővé teszi annak begyűjtését a `CoinService`‑en keresztül【674288901791015†L2-L5】.

### 🧠 Fejlesztési részletek

- A csempe egy egyszerű Card, amely kezeli az elérhető/nem elérhető állapotokat【674288901791015†L8-L14】.
- A `CoinService` kérdezi le, hogy az adott napon már begyűjtötte‑e a user a jutalmat; a gombnyomás bónusz jóváírást indít és frissíti a státuszt【674288901791015†L12-L14】.
- Animált ikon vagy konfetti effekt jelzi a sikeres begyűjtést (opcionális)【674288901791015†L14-L15】.

### 🧪 Tesztállapot

- Unit teszt: a `CoinService` napi bónusz függvényének helyes működése【674288901791015†L16-L19】.
- Widget teszt: a csempe két állapotban (elérhető / begyűjtve)【674288901791015†L16-L20】.
- UI teszt: gomb megnyomása után a TippCoin egyenleg frissül és a státusz megváltozik【674288901791015†L18-L21】.

### 🌍 Lokalizáció

Kulcsok: `home_tile_daily_bonus_title`, `home_tile_daily_bonus_button_claim`, `home_tile_daily_bonus_already_claimed`【674288901791015†L24-L28】.

### 📎 Kapcsolódások

- `CoinService` – a napi bónusz lekérdezése és jóváírása【674288901791015†L31-L33】.
- HomeScreen – a csempe megjelenítése.
- Codex szabályfájlok: `codex_context.yaml`, `localization_logic.md`, `service_dependencies.md`【674288901791015†L35-L39】.
