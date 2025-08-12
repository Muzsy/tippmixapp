# Odds Drift Prompt – frontend ellenőrzés és megerősítés (API‑Football)

## Kontextus

Az API‑Football átállás után a fogadás véglegesítése előtt szükség van egy automatizált ellenőrzésre: ha a kiválasztott tippek odds értékei időközben megváltoztak, a felhasználót figyelmeztetjük és megerősítést kérünk (**odds drift prompt**). A jelenlegi kódbázisban elérhető az előző lépésben létrehozott `TicketService` stub (callable `createTicket` meghívásához), valamint az `ApiFootballService`.

## Cél (Goal)

Backend változtatás nélkül, **frontend oldalon**:

1. összehasonlítani a kiválasztott tippek korábban látott `oddsSnapshot` értékeit az **aktuális** oddsokkal (API‑Football),
2. ha eltérés van a beállított küszöbnél nagyobb mértékben, **prompt** megjelenítése,
3. a felhasználó döntése alapján **folytatni** (új odds elfogadása és tovább a `createTicket`‑re) vagy **megszakítani** a fogadást.

## Feladatok

* [ ] Odds drift ellenőrző segéd: `lib/services/odds_drift_checker.dart` – friss odds lekérése az `ApiFootballService`‑től, diff számítás
* [ ] Drift modell: `lib/models/odds_drift.dart` – eltérés típusok, régi/új értékek tip szinten
* [ ] Prompt komponens: `lib/widgets/odds_drift_dialog.dart` – lista a változásokról, Elfogad / Mégse gombok
* [ ] `TicketService` bővítése: `confirmAndCreateTicket(...)` – először drift ellenőrzés, szükség esetén prompt; döntés után hívja a callable‑t
* [ ] Konfigurálható küszöb: alapértelmezés `±0.05` (lebegőpontos különbség), override paraméterben
* [ ] Unit tesztek a checkerre (mockolt `ApiFootballService`), golden nélkül

## Acceptance Criteria / Done Definition

* [ ] Nincs UI regresszió: a meglévő flow megy tovább, de ha drift van, **kötelező** prompt jelenik meg (a hívó képernyőn)
* [ ] A checker csak az érintett tippeket jelzi; **nincs** felesleges hálózati terhelés (batch lekérés/összevonás)
* [ ] Tesztek: „nincs drift”, „kisebb mint küszöb”, „nagyobb mint küszöb” esetek zöldek
* [ ] `flutter analyze` hibamentes

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_odds_drift_prompt_frontend.yaml`
* Előzmények: `ticket_create_flow_atomic.md`, `api_football_frontend_service_and_oddsapi_removal.md`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

Felhasználói megerősítés kérdezése **odds változás** esetén a fogadás véglegesítése előtt.

### 🧠 Fejlesztési részletek

* **Checker API**

  * Bemenet: a felhasználó által kiválasztott tippek listája (fixtureId, market, selection, **oddsSnapshot**).
  * Művelet: `ApiFootballService` használatával friss odds lekérés **batchben**, majd diff.
  * Kimenet: `OddsDriftResult { changedTips: DriftItem[], hasBlockingDrift }`.
* **Dialog**

  * Mutatja tippenként a régi→új oddsot; jelöli az irányt (↑/↓); elfogadás esetén a hívó kap vissza egy új `acceptedOdds` listát.
* **TicketService integráció**

  * Új metódus: `Future<CreateTicketResult> confirmAndCreateTicket(BuildContext ctx, CreateTicketParams p, {double threshold=0.05});`
  * Lépések: ellenőrzés → ha nincs drift (vagy < küszöb): hívja a backend `createTicket`‑et; ha drift ≥ küszöb: megnyitja a dialogot.
* **Teljesítmény**

  * A checker összevonja azonos fixture‑öket; egy lekéréssel kéri le a szükséges piacokat.

### 🧪 Tesztállapot

* Unit: három fő eset (nincs drift / kis drift / nagy drift); több tipp, több fixture.
* Widget teszt: a dialog megjelenik és visszaadja a felhasználói döntést (alap render, nem golden).

### 🌍 Lokalizáció

* Új UI szövegek: „Odds megváltozott”, „Régi”, „Új”, „Elfogad”, „Mégse”. (Következő vászonban ARB‑be emelés.)

### 📎 Kapcsolódások

* `lib/services/api_football_service.dart` – friss odds forrása
* `lib/services/ticket_service.dart` – új belépési pont a fogadáshoz drift‑védelemmel
* Későbbi vászon: i18n stringek ARB‑be tétele és golden/accessibility ellenőrzés
