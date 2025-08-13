# Fix: OddsAPI‑maradék üzenetek (l10n) + H2H piacok megjelenítése API‑Footballból

## Mi a hiba?

* A **Fogadások** képernyőn hiba esetén ez jelenik meg: *„Ismeretlen hiba az OddsAPI‑tól”*. Ez akkor is így maradt, ha már az API‑Football a forrás.
* A tippkártyákon **„Nincs elérhető piac”**, mert az `ApiFootballService.getOdds()` csak a *fixtures* adatait tölti be, a **bookmakers/markets/outcomes** lista üres (`bookmakers: const []`).

## Gyökérok

* **L10n maradvány**: a három ARB fájlban (HU/EN/DE) az `api_error_*` feliratok kifejezetten „Odds API”-t említenek.
* **Hiányzó odds‑join**: a `lib/services/api_football_service.dart` jelenleg **nem** kéri le a /odds végpontot, ezért nincs H2H (1X2) piac a kártyához.

## Megoldás (összefoglaló)

1. **L10n tisztítás** (provider‑semleges):

   * `api_error_key` → „Érvénytelen API kulcs”
   * `api_error_limit` → „Túl sok kérés az adatszolgáltató felé”
   * `api_error_network` → „Hálózati hiba az adatszolgáltató elérésekor”
   * `api_error_unknown` → „Ismeretlen hiba az adatszolgáltatótól”
   * EN/DE megfelelő frissítése, majd `flutter gen-l10n` futtatása.

2. **Minimál odds‑join (H2H)**:

   * `ApiFootballService.getOdds()` a *fixtures* lista összeállítása után **per‑fixture** meghívja az `getOddsForFixture(fixtureId)` metódust.
   * Új privát parser: `_parseH2HBookmakers(...)` az API‑Football `response[].bookmakers[].bets[].values[]` struktúrából **egy** H2H piacot épít:

     * **Market**: `key='h2h'`
     * **Outcomes**: *Home/Draw/Away* → appban *Hazai / X / Vendég* gombok
     * **Bookmaker**: az első elérhető fogadóiroda (a kulcs egyszerű „slug” a névből)
   * Ha egy fixture‑re nincs odds, az esemény bekerül üres markets‑szel (jelenlegi fallback viselkedés megmarad).

## Érintett fájlok

* `lib/l10n/app_hu.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_de.arb` – sztringek cseréje
* `lib/services/api_football_service.dart` – import bővítés, odds‑join, parser + helper slug

## Elfogadási kritériumok

* Hibaüzenetek **nem** említik többé az „Odds API”-t egyik nyelven sem.
* A Fogadások listán a tippkártyákon **megjelenik a H2H** (Hazai / X / Vendég) – legalább az első elérhető bookmaker alapján.
* `flutter analyze` hibamentes; a meglévő tesztek futnak (`flutter test`).

## Manuális teszt

1. Indítsd az appot, nyisd meg a **Fogadások** képernyőt.
2. Provokálj hibaállapotot (pl. ideiglenesen rossz kulcs) → üzenet **„…adatszolgáltatótól”**, nem „OddsAPI”.
3. Normál futásnál a tippkártyákon megjelennek a gombok: **Hazai / X / Vendég**; a „Tovább i fogadások” gomb aktívvá válik, ha tipp került a szelvényre.

> Megjegyzés: a teljes market‑mappinget (handicap, O/U, BTTS, stb.) **később** bővítjük külön vászonban – itt csak a H2H a cél, hogy tesztelhető legyen a szelvény‑flow.
