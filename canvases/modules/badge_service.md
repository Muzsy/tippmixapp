## 🏅 BadgeService modul

### 🎯 Funkció

A `BadgeService` felelős a badge‑ek valós idejű kiosztásáért a TippmixApp alkalmazásban.  Minden olyan esemény után meghívható, amely potenciálisan új badge kiosztását vonhatja maga után, például nyertes fogadás, statisztika változás vagy napváltás【676551470588128†L0-L12】.

### 🧠 Fejlesztési részletek

- A szolgáltatás bemenetei lehetnek: szelvény lezárása (nyertes tipp), statisztika változása vagy napváltás【676551470588128†L6-L11】.
- Fő metódusok:
  - `evaluateUserBadges(UserStats stats)` – meghatározza, hogy a felhasználó aktuális statisztikái alapján mely badge‑eket érdemelte ki【676551470588128†L14-L18】.
  - `assignNewBadges(String userId)` – lekéri az eddigi badge‑eket a Firestore‑ból, és új badge esetén beírja a `badges` kollekcióba【676551470588128†L18-L21】.
- A `badgeConfigs` lista alapján iterál minden badge‑en, és kiértékeli a `BadgeCondition` enumhoz tartozó szabályokat【676551470588128†L21-L22】.
- A felhasználók badge‑ei a `users/{userId}/badges` Firestore kollekcióban tárolódnak【676551470588128†L24-L25】.

### 🧪 Tesztállapot

Egységtesztek a `BadgeCondition` minden esetét külön metódusban tesztelik, valamint a Firestore‑ba írást mockolva ellenőrzik az új badge elnyerését【676551470588128†L26-L33】.

### 🌍 Lokalizáció

A szolgáltatás maga nem lokalizál, de az UI‑nak lokalizált badge‑kulcsokat ad vissza; az ikonkezelés és címfordítás a `profile_badge.dart` komponens feladata【676551470588128†L34-L39】.

### 📎 Kapcsolódások

- `badge_config.md` – a konkrét badge‑ek listája.
- `badge_model.md` – a badge adatmodellje.
- `stats_service.md` – a felhasználói statisztikák szolgáltatója【676551470588128†L40-L44】.
- Firestore: `/users/{userId}/badges` kollekció【676551470588128†L24-L25】.
- Codex szabályzat: `codex_context.yaml`, `service_dependencies.md`, `priority_rules.md`【676551470588128†L39-L46】.
