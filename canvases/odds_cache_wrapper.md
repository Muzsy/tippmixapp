## 🎯 Funkció

Az `OddsCacheWrapper` célja az OddsAPI kvóta-problémák csökkentése, a válaszok cache-elésével. Azonos kérésre (pl. azonos sportesemény azonos időben) nem hívjuk újra az API-t, hanem SharedPreferences-ből visszaadjuk a korábbi választ, ha az még érvényes.

## 🧠 Fejlesztési részletek

A `OddsApiService` mellé egy wrapper réteg kerül: `OddsCacheWrapper`.

* Beépül a meglévő odds lekérdezési logika köré
* Cache kulcs: endpoint + lekérdezési paraméterek string alapú hash-e
* Tárolás: `SharedPreferences` (lokális key-value)
* TTL: 15 perc
* Új kérés esetén először a cache-t ellenőrzi, csak ha nincs érvényes adat, akkor hívja meg a `OddsApiService.fetchOdds()`-ot

Fontos:

* Cache-be mentés időbélyeggel (`timestamp`) együtt történik
* A JSON választ stringként tároljuk és dekódoljuk vissza
* Támogatott: eseménylista és odds részletek (nem user-specifikus)
* Nem cache-elünk, ha a HTTP válasz nem 200, vagy hibaüzenetet tartalmaz

## 🧪 Tesztállapot

* [ ] Cache miss → API hívás történik
* [ ] Cache hit → nem történik API hívás
* [ ] Cache expiry → 15 perc után újra hívás
* [ ] Hibás válasz nem kerül cache-be

## 🌍 Lokalizáció

* Az OddsApiService által dobott hibaüzenetek lokalizálva jelennek meg (pl. "Nem sikerült lekérni az oddsokat")
* `AppLocalizations`-ön keresztül történik a hiba-visszajelzés

## 📎 Kapcsolódások

* `OddsApiService` – meglévő API hívások becsomagolása
* `lib/services/odds_cache_wrapper.dart` – új fájl
* `SharedPreferences` package – bevezetendő ha még nincs
* Widgetek, amelyek odds-ot kérnek be (pl. odds\_list\_screen) automatikusan profitálnak
