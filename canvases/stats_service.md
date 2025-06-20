## 🎯 Funkció

A `StatsService` célja, hogy a felhasználókhoz kapcsolódó statisztikai adatokat kiszámítsa és streamelje a felhasználói felület (pl. ranglista, profiloldal) számára. Az adatok alapját a Firestore-ban tárolt szelvények és felhasználói mezők adják.

## 🧠 Fejlesztési részletek

* A szolgáltatás képes különböző `LeaderboardMode` típusok szerint lekérni és feldolgozni statisztikákat.
* Alap statisztikák (Sprint1):

  * `coin`: közvetlenül a user dokumentumból
  * `totalBets`, `totalWins`: tipp-szelvények alapján számítva
  * `winrate`: `totalWins / totalBets` (ha >0)
* A statisztikák `UserStatsModel` példányokba töltődnek be.
* Adatszolgáltatás módja: `Stream<List<UserStatsModel>>`, real-time frissítéssel (Firestore query snapshot).
* Előkészített metrikák, de nem kerülnek még kiszámításra: `ROI`, `currentWinStreak`, `averageOdds`, `badgesUnlocked`.
* A szolgáltatás célja, hogy a későbbi BigQuery-integrációval cserélhető legyen (absztrakcióval)

## 🧪 Tesztállapot

* Unit teszt: különböző LeaderboardMode-ok esetén megfelelő lekérdezés és rendezés történik-e
* Szimulált Firestore-környezet mock adatokkal
* Üres állapot, hibás Firestore query kezelése

## 🌍 Lokalizáció

* Közvetlen szövegkimenetet nem tartalmaz, de a `UserStatsModel` szövegértékei (pl. "100 TippCoin", "80% win-rate") UI komponensekben lokalizálva jelennek meg.

## 📎 Kapcsolódások

* `UserStatsModel` – a kiszámított statisztikák struktúrája
* `firestore.rules` – a szelvények és user dokumentumok olvashatósága
* `betting_ticket_data_model.md` – a tippelési adatok forrása
* `leaderboard_screen.dart` – a fő felhasználója a streamnek

## 📚 Input dokumentumok

* `docs/tippmix_app_teljes_adatmodell.md`
* `docs/betting_ticket_data_model.md`
