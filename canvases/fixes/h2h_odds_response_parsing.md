# H2H – Odds JSON helytelen feldolgozása (gyökérok) és javítás

## Mi a hiba?

A H2H piacok lekérése után a kód **nem** a megfelelő JSON‑útvonalat olvassa: a parser `json['markets']` kulcsot keres, miközben az API‑Football **/odds** válasza `response → [bookmakers → [bets → values]]` szerkezetű.

Következmény: mindig `null` lesz a H2H piac → minden kártyán **„Nincs elérhető piac”.**

> Megjegyzés: a dokumentációban a „Head to Head” (fixtures/headtohead) **mérkőzés‑történetet** ad, nem fogadási piacot. A H2H (1X2) fogadási piac az **odds** végponton érkezik.

## Javítás

* **Parser csere** a `MarketMapping.h2hFromApi(...)` függvényben:

  * Bejárás: `for response in json['response']` → `for bookmaker in response['bookmakers']` → `for bet in bookmaker['bets']`.
  * Bet‑név aliasok: `match winner`, `1x2`, `full time result`, `match result`, `winner` (kisbetűs összevetés).
  * Érték aliasok: `home/draw/away` **vagy** `1/X/2`.
  * Első érvényes bookmaker/bet alapján állítjuk össze a **három kimenetet** (1, X, 2) és visszaadunk egy `H2HMarket`‑et.
* **Fallback**: ha nincs érvényes odds, `null`.

## Elfogadási kritériumok

* [ ] Legalább egy ligában azonnal megjelenik az 1/X/2 három gomb **minden kártyán**.
* [ ] Az eddigi „mindenhol nincs piac” állapot megszűnik.
* [ ] `flutter analyze` + `flutter test` zöld.

## Érintett fájlok

* `lib/services/market_mapping.dart` – új `h2hFromApi` implementáció
* (teszt) `test/services/market_mapping_h2h_parsing_test.dart` – minta odds JSON‑nal

## Kapcsolódás

* Maradhat a korábbi javítás (season + bet=1X2); ez a parser‑fix **kiegészíti**, nem helyettesíti azt.
