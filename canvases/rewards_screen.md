## 🎁 RewardsScreen – Jutalomgyűjtő képernyő

### 🌟 Funkció

A RewardsScreen egy önálló képernyő, amely összegyűjti az összes aktuálisan átvehető jutalmat a felhasználó számára (napi bónusz, badge, kühdetés, push jutalom, klubjutalom). Célja az engagement erősítése és a rendszeres visszatérés ösztönzése.

---

### 🧠 Fejlesztési részletek

* Route: `/rewards`
* Navigáció:

  * Drawer menü: `menuRewards`
  * Push értesítések célképernyője lehet
* UI komponensek:

  * RewardCard: ikon, név, leírás, átvétel gomb
  * Állapot alapján aktív ("Átvétel") vagy passzív ("Már átvetted")
  * Lista/grid struktúra (ListView/GridView)

---

### 💡 Működési logika

* `RewardModel` tartalmaz minden információt:

  * id, type, title, description, iconName, isClaimed, onClaim()
* `RewardService` gyűjti össze a napi/egyedi jutalmakat
* Claim: a hozzá tartozó service végzi (pl. `DailyBonusService.claim()`)

---

### 🎨 Animáció + állapotváltás

1. Jutalom átvételekor:

   * animált pipa vagy konfetti
   * gomb átvált: "Átvéve"
2. Késleltetett eltűnés:

   * 1-2 mp után fade-out animációval eltűnik
3. Lista frissítés:

   * a begyűjtött reward törölésre kerül, nem jelenik meg újrafetch esetén sem

---

### 🧪 Tesztállapot

* Widget teszt: megjelennek-e a jutalmak helyesen, átvétel után eltűnik-e az elem
* Unit teszt: RewardService, napi badge/bonus claim ellenőrzés
* Lokalizációs sanity test: minden kulcs megjelenik-e 3 nyelven

---

### 🌍 Lokalizáció

ARB kulcsok:

```json
{
  "menuRewards": "Jutalmaim",
  "rewardTitle": "Átvehető jutalmak",
  "rewardClaim": "Átvétel",
  "rewardClaimed": "Már átvetted",
  "rewardEmpty": "Nincs elérhető jutalom"
}
```

---

### 📌 Kapcsolódások

* `daily_bonus_service.dart`, `badge_service.dart`, stb. → claim logikák
* `RewardModel`, `RewardService` → listakezelés
* `routing_integrity.md` → drawer + route megfelelő bekötése
* `localization_logic.md` → lokalizációs kulcsok definiálása
