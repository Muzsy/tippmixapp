# API-Football átállás – Frontend service bekötése & OddsAPI kivezetés (Flutter)

## Kontextus

A frontend jelenleg az **OddsAPI**-ra épül (`lib/services/odds_api_service.dart`, cache: `lib/services/odds_cache_wrapper.dart`, állapot: `lib/providers/odds_api_provider.dart`, modellek: `lib/models/odds_*.dart`). A UI elemek (pl. `lib/screens/events_screen.dart`, `lib/widgets/event_bet_card.dart`) az `OddsEvent` belső modellre támaszkodnak. Cél, hogy az **API‑Football** szolgáltatóra álljunk át úgy, hogy az app-beli modellek és UI-k minimálisan vagy egyáltalán ne változzanak.

## Cél (Goal)

Bevezetni az **ApiFootballService**-t a frontendben, amely az API‑Football `fixtures` (+ szükség esetén odds) adataiból állít elő **belső** `OddsEvent` listát. Bekötni az állapotkezeléshez (ahol eddig az `OddsApiService` volt), majd **kivezetni** az OddsAPI-specifikus kódot és teszteket. A cache réteg megmarad.

## Feladatok

* [x] Új szolgáltató: `lib/services/api_football_service.dart` – publikus API kompatibilis az eddigi hívókkal (ugyanaz a metódus-szignatúra / visszatérés: `OddsEvent` lista)
* [x] Market mapping: `lib/services/market_mapping.dart` – 1X2, O/U, BTTS, (opcionálisan AH) kódok egységesítése
* [x] Állapotkezelés bekötése: az eddigi provider a `ApiFootballService`-t használja (azonos interface)
* [x] Cache réteg változatlan; kulcsképzés igazítása, ha mezőnév eltérés van
* [x] OddsAPI fájlok kivezetése: `lib/services/odds_api_service.dart`, OddsAPI‑specifikus DTO-k/utility-k és a hozzájuk tartozó tesztek eltávolítása
* [x] Új unit/flow tesztek: `test/services/api_football_service_test.dart` (DTO parse, alap flow)
* [x] `flutter analyze` és `flutter test` zöld

## Acceptance Criteria / Done Definition

* [x] A UI (events lista és tippkártya) **változtatás nélkül** fut az `ApiFootballService`-re építve
* [x] A kódbázisban nincs `oddsapi` / `the-odds-api` hivatkozás a frontendben
* [x] Új market mapping tesztelt (legalább 10 minta)
* [x] Cache működik (TTL, üres lista/hiba fallback változatlan)
* [x] `flutter analyze` hibamentes; `flutter test` zöld

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_api_football_frontend_service.yaml`
* Backend cutover vászon: `api_football_backend_cutover_and_oddsapi_removal.md`
* Átállási terv: `Api Football Migration Plan.pdf`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

API‑Football‑ra épülő frontend szolgáltató bevezetése (`ApiFootballService`) az `OddsEvent` kompatibilitás megőrzésével; régi OddsAPI kód kivezetése.

### 🧠 Fejlesztési részletek

* **Service API**: a régi hívók továbbra is `Future<List<OddsEvent>>`‑et kapnak; hibaágak maradnak (quota, 401/429 → egységes hibatípus)
* **Lekérés**: `fixtures` dátum/league paraméterrel; ha szükséges, odds join (később finomítható)
* **Mapping**: `fixture.status.short`, `teams`, `goals`, (opcionálisan odds markets → belső `OddsMarket`/`OddsOutcome`)
* **Cache**: továbbra is 15 perc TTL; kulcsban sport/league/időablak
* **Biztonság**: kliens oldali kulcskezelés nem része ennek a vászonnak; a jelenlegi architektúrához igazodunk

### 🧪 Tesztállapot

* Új tesztek: DTO parse (mintaválasz), alap flow (lista betölt), market mapping (10 minta)
* Régi OddsAPI tesztek törölve

### 🌍 Lokalizáció

* Nincs új UI‑szöveg; ARB/l10n nem módosul

### 📎 Kapcsolódások

* `lib/providers/odds_api_provider.dart` (vagy az aktuális odds provider) – a service injektálása itt történik
* `lib/services/odds_cache_wrapper.dart` – változatlan használat
* Következő lépés: opcionális logó‑URL bekötés a kártyákon (külön vászon)
