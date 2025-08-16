# 🎯 Funkció

A fogadási oldal hálózati megbízhatóságának finomhangolása az API‑Football integráción:

1. **Fixtures lekérés (lista) – 1× retry 200 ms backoff-fal** a `GET /fixtures?date=...` hívásnál, hogy egységes legyen a H2H hívásokkal.
2. **Guard teszt a H2H lekérésre**: ha `fixtureId <= 0`, ne legyen hálózati hívás.

Meglévő funkciók nem sérülhetnek. A változtatások kizárólag kis kockázatú stabilitási javítások.

---

# 🧠 Fejlesztési részletek

**Érintett fájlok a projektben (tippmixapp.zip alapján):**

* `tippmixapp-main/lib/services/api_football_service.dart`

  * Jelenleg a fixtures lekérés időkorlátos (`timeout: 10s`), de nincs retry; a H2H (`getOddsForFixture`) már tartalmaz 1× retry mintát.
* `tippmixapp-main/lib/widgets/event_bet_card.dart`

  * Kártya „lokális‑első” render, H2H csak hiány esetén hálózat, cache‑kulcs összeállítása.
* Tesztfájlok (részlet):

  * `tippmixapp-main/test/services/api_football_service_odds_url_test.dart`
  * `tippmixapp-main/test/services/api_football_service_odds_fallback_test.dart`
  * `tippmixapp-main/test/services/fixtures_date_filter_test.dart`
  * `tippmixapp-main/test/widgets/event_bet_card_h2h_render_test.dart`

**Változtatások:**

1. **Fixtures 1× retry**
   A `api_football_service.dart` fixtures részében a `http.get(...).timeout(...)` köré azonos mintájú próbálkozás kerül, mint a `getOddsForFixture` metódusban: egy `_attempt()` segédfüggvény, majd `try { res = await _attempt(); } catch { await Future.delayed(200ms); res = await _attempt(); }`.

2. **H2H guard unit teszt**
   Új teszt: `test/services/h2h_guard_no_network_test.dart` – ellenőrzi, hogy `fixtureId<=0` esetén a `getH2HForFixture` **nem** hív hálózatot (mock klient hívásszámláló=0).

3. **Fixtures retry unit teszt**
   Új teszt: `test/services/fixtures_retry_test.dart` – az első `_attempt()` kivételt dob (pl. Timeout/ClientException), a második sikeres; elvárt: a metódus visszatér használható JSON‑nal és a hívásszám pontosan 2.

**Nem változik:**

* API végpontok, paraméterezés (date/country/league; H2H: `bet=1` elsődlegesen),
* H2H 60s memóriacache viselkedés,
* UI/UX és a kártya megjelenés logikája.

---

# 🧪 Tesztállapot

**Meglévő**: URL, fallback, dátumszűrő, lokális‑első widget render tesztek.

**Új**:

* `h2h_guard_no_network_test.dart`: negatív `fixtureId` & null/0 eset – nincs hálózati hívás.
* `fixtures_retry_test.dart`: 1× retry viselkedés – első hívás bukik, második sikerül.

**Futtatás**:

* `flutter test`  (a projekt meglévő mintája szerint; szükség esetén `.env` mock betöltése a tesztek elején)
* `flutter analyze --no-fatal-infos lib test`  (csak informatív lint)

---

# 🌍 Lokalizáció

* A változtatások hálózati rétegben és tesztekben történnek; felhasználói szöveg nem változik.
* Hibaüzenet kulcsok (pl. `api_error_*`) nem módosulnak.

---

# 📎 Kapcsolódások

* **API‑Football**: `GET /fixtures` (date/country/league), `GET /odds` (fixture, season, bet=1 elsődlegesen).
* **Kártya**: `EventBetCard` lokális‑első (létező H2H esetén nincs hálózat).
* **Cache**: H2H 60s memóriacache (változatlan). Lista‑cache viselkedéséhez nem nyúlunk.

---

## Kockázatkezelés

* A retry kizárólag a fixtures hívásnál kerül be, 1 próbálkozásra korlátozva (200 ms backoff).
* Nem érintjük az adatmodelleket/mapper logikát, így a render és a tétleadás folyamata változatlan marad.

## Elfogadási kritériumok

* A fogadási oldal működése változatlan (vizuális/regressziós eltérés nélkül).
* Instabil hálózat mellett is ritkább az üres lista (transziensekre nem omlik el).
* Új tesztek zölden futnak és nem flakyk.
