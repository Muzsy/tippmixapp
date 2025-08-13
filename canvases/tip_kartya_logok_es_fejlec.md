# Tippkártya – Ország/Liga fejléccel és csapat‑/liga‑logóval

## 🎯 Funkció

A fogadási kártyán (event bet card) jelenjen meg:

* bal felső sor: **Ország • Liga** (a jobb oldalhoz igazítva)
* a csapatok **monogram/avatarképe** a csapatnevek mellett
* (opcionális) a liga **címere** az ország‑név előtt
* hibatűrő megjelenítés: ha nincs elérhető kép, **monogramos kör badge** látszik

A megoldás **nem sérti** a meglévő működést (H2H piacok, tipp hozzáadása, FAB logika), visszafelé kompatibilis (`OddsEvent` új, opcionális mezőkkel bővül).

## 🧠 Fejlesztési részletek

**Adatmodell bővítés (nem breaking):**

* `OddsEvent` új opcionális mezők:

  * `countryName` (String?)
  * `leagueName` (String?)
  * `leagueLogoUrl` (String?)
  * `homeLogoUrl`, `awayLogoUrl` (String?)
* Ezeket az `ApiFootballService` tölti ki az API‑Football `fixtures` válaszából (team.logo, league.logo, league.country).

**UI komponensek:**

* Új, belső widgetek, dependency nélküli megoldással (nem igényel `cached_network_image`):

  * `TeamBadge` – kör alakú 32px avatar, **Image.network** fallback‑kel monogramra
  * `LeaguePill` – kisméretű jelvény (12–14px font), ikon helyén (ha van) league logo 16px‑en
* `event_bet_card.dart` módosításai:

  * Fejléc sor: jobb oldalra zárt `Text.rich`: `countryName • leagueName`
  * Csapatsor: név előtt `TeamBadge(logoUrl, initials)`
  * Layout marad rugalmas; nincs hatás az odds gombokra

**Mapping (ApiFootballService):**

* A fixtures lekérésből:

  * `league.name` → `leagueName`
  * `league.country` → `countryName`
  * `league.logo` → `leagueLogoUrl`
  * `teams.home.logo`/`teams.away.logo` → `homeLogoUrl`/`awayLogoUrl`
* Ha bármelyik hiányzik → UI monogram fallback.

**Teljesítmény & cache:**

* Képek betöltése sima `Image.network`‑kel, `errorBuilder` és `loadingBuilder` használatával.
* A későbbiekben opcionálisan cserélhető `cached_network_image`‑re (külön vászonban), jelen feladat **nem** érinti a `pubspec.yaml`‑t.

**Biztonság/robosztusság:**

* Üres/hiányzó mezők → text/monogram fallback.
* A régi `OddsApiService` nincs érintve.

## 🧪 Tesztállapot

* **Widget tesztek:**

  * `TeamBadge` monogram fallback (érvényes/hibás URL)
  * `event_bet_card` fejléc: megjeleníti a `countryName • leagueName` sztringet
* **Dart analyze/test** zölden fut.

## 🌍 Lokalizáció

* A fejléc tartalma adat (ország/ liga neve az API‑ból) → **nem igényel** új ARB kulcsot.
* Ha szükség lesz címkére („Frissítve:” már létezik), külön i18n vászonon bővítjük.

## 📎 Kapcsolódások

* API‑Football integráció (fixtures mapping)
* Tippkártya UI: `lib/widgets/event_bet_card.dart`
* Szolgáltató: `lib/services/api_football_service.dart`
* Model: `lib/models/odds_event.dart`
