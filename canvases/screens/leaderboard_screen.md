# 🏆 Ranglista képernyő (LeaderboardScreen)

A ranglista képernyő célja, hogy a TippmixApp felhasználóit különböző metrikák alapján rangsorolja (TippCoin, win‑rate, streak, stb.), így motiválva a közösségi versenyzést【974883664112516†L2-L9】.

## 🎯 Funkció

- Rendezhető és szűrhető lista, amely alapértelmezetten TippCoin szerint rendezett, de további módokkal (`byWinrate`, `byStreak`) bővíthető【974883664112516†L6-L9】.
- A felhasználó saját sora kiemelten jelenik meg, ezzel is növelve az önreflexiót【974883664112516†L11-L12】.
- Infinite scroll és shimmer loader támogatása (elő van készítve)【974883664112516†L11-L13】.

## 🧠 Felépítés

- A ranglista komponens `StatsService` által szolgáltatott adatokból építkezik stream formájában【974883664112516†L9-L10】.
- A `UserStatsModel` külön kezeli a megjelenített statisztikai adatokat, nem közvetlenül a `UserModel`‑ből dolgozik【974883664112516†L9-L11】.
- A UI váltása `SegmentedButton` vagy `DropdownButton` vezérléssel történik【974883664112516†L8-L9】.

## 🧪 Tesztállapot

Widget tesztek a különböző rangsorolási szempontokat, az üres állapotot és az infinite scroll működését vizsgálják【974883664112516†L14-L18】.  Emellett lokalizációs tesztek biztosítják a címkék helyes megjelenését【974883664112516†L20-L25】.

## 📎 Modul hivatkozások

- `stats_service.md` – statisztikák szolgáltatója.
- `user_stats_model.md` – modell, amely a ranglista adatait tartalmazza.
- Firestore jogosultsági szabályok (`firestore.rules`) – a `users` kollekció olvasására vonatkozóan【974883664112516†L31-L32】.
