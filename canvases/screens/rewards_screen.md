# 🎁 Jutalmak képernyő (RewardsScreen)

Ez a vászon a TippmixApp jutalomgyűjtő képernyőjét írja le.  A RewardsScreen összegyűjti az összes aktuálisan átvehető jutalmat – napi bónusz, badge, kihívás, push jutalom vagy klubjutalom –, így ösztönözve a rendszeres visszatérést【264444429103067†L0-L4】.

## 🎯 Funkció

- A képernyő route neve `/rewards`, és a főmenüben (drawer menü: `menuRewards`) érhető el【264444429103067†L10-L15】.
- Minden jutalom kártyaként jelenik meg: ikon, név, leírás és átvételi gomb【264444429103067†L16-L19】.
- A jutalom állapotától függően a gomb aktív („Átvétel”) vagy passzív („Már átvetted”)【264444429103067†L16-L20】.

## 💡 Működési logika

- `RewardModel` definiálja az egyes jutalmak mezőit (id, type, title, description, iconName, isClaimed, onClaim())【264444429103067†L23-L28】.
- `RewardService` gyűjti össze a napi és egyedi jutalmakat, a claim műveleteket pedig a megfelelő szolgáltatások (pl. `DailyBonusService.claim()`) hajtják végre【264444429103067†L25-L30】.
- Animációk: jutalom átvételekor animált pipa vagy konfetti, majd fade‑out animációval eltűnik a kártya【264444429103067†L33-L45】.

## 🧪 Tesztállapot

Widget tesztek vizsgálják, hogy a jutalmak helyesen jelennek meg, és átvétel után eltűnnek【264444429103067†L48-L52】.  Unit tesztek ellenőrzik a RewardService logikáját és a különböző claim függvények működését【264444429103067†L50-L52】.  Lokalizációs tesztek biztosítják, hogy minden kulcs mindhárom nyelven elérhető legyen【264444429103067†L52-L53】.

## 🌍 Lokalizáció

Az ARB fájlok tartalmazzák a jutalom képernyő kulcsait (`menuRewards`, `rewardTitle`, `rewardClaim`, `rewardClaimed`, `rewardEmpty`)【264444429103067†L56-L67】.

## 📎 Modul hivatkozások

- `daily_bonus_service.md`, `badge_service.md`, `challenge_service.md` – jutalmak szolgáltatói.
- `reward_model.dart`, `reward_service.dart` – a jutalmak modellje és szolgáltatója.
- `routing_integrity.md`, `localization_logic.md` – route és lokalizációs szabályok.
