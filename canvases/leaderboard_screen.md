## 🎯 Funkció

A `LeaderboardScreen` célja a TippmixApp felhasználóinak rangsorolása különböző metrikák alapján (pl. TippCoin, win-rate). Ez a képernyő biztosítja a közösségi verseny érzését, motiválja a felhasználókat a rendszeres használatra, és előkészíti a későbbi gamifikációs elemek (pl. badge-ek, kihívások) bevezetését.

## 🧠 Fejlesztési részletek

* A képernyő fő komponense egy rendezhető és szűrhető ranglista, amely különböző statisztikai mutatók szerint képes megjeleníteni a felhasználók adatait.
* A rangsor alapértelmezetten TippCoin szerint rendezett (`LeaderboardMode.byCoin`), de elő van készítve további módokra is (`byWinrate`, `byStreak`, stb.).
* A UI-t `SegmentedButton` vagy `DropdownButton` segítségével lehet váltani a különböző rangsorolási szempontok között.
* A `StatsService` szolgáltatja a szükséges adatokat `Stream<List<UserStatsModel>>` formájában.
* A `UserStatsModel` külön modellként kezeli a megjelenített statisztikákat, nem közvetlenül a `UserModel`-ből dolgozik.
* Kiemelt megjelenítést kap a saját felhasználó ("You" sor).
* Előkészítésre kerül az infinite scroll (Firestore `startAfter` logika).

## 🧪 Tesztállapot

* Widget tesztelés alapszintű mock adatokkal (pl. üres lista, top 3 user).
* Lokális tesztelés Firebase Emulatorral, valós Firestore struktúra szimulálása mellett.
* Tesztelendő: UI váltások `LeaderboardMode` szerint, shimmer loader, üres állapot.

## 🌍 Lokalizáció

* A `LeaderboardScreen` minden szövegeleme a `AppLocalizations` enum-alapú kulcsrendszeréből dolgozik.
* Szövegek: "Ranglista", "Helyezés", "Felhasználó", "TippCoin", "Nyerési arány", "Te vagy itt", stb.
* Minden kifejezés három nyelven (hu/en/de) kerül lokalizálásra.

## 📎 Kapcsolódások

* `StatsService` – a statisztikák előállítása
* `UserStatsModel` – a ranglista megjelenített adatai
* `user_model.dart` – a háttérben használt alap user-adatok
* `firestore.rules` – jogosultság a `users` kollekció olvasásához

## 📚 Input dokumentumok

* `docs/tippmix_app_teljes_adatmodell.md`
* `docs/betting_ticket_data_model.md`
* `docs/canvases_odds_api_integration.md` (későbbi odds-alapú statok előkészítéséhez)
