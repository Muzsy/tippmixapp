# Szelvénykezelés – Finalizer & payout: **atomikus** jóváírás és duplázás‑védelem (Cloud Functions)

## Kontextus

Az API‑Football bekötés elkészült (backend cutover), a `match_finalizer.ts` már az új providert használja. Következő lépés, hogy a szelvények kiértékelése **konzisztensen és idempotensen** frissítse a ticket státuszát és a felhasználó TippCoin egyenlegét. Cél az **atomikus** művelet: vagy minden változás megtörténik, vagy semmi.

## Cél (Goal)

A `match_finalizer` kiegészítése úgy, hogy:

1. minden *pending* ticket tippjeit API‑Football alapján eldönti (`won|lost|void|pending`),
2. ha **minden** tip döntött (nincs `pending`), akkor **egyetlen Firestore tranzakcióban**

   * frissíti a ticket `status`‑át és `payout` mezőjét (az **oddsSnapshot** alapján),
   * és **jóváírja** a felhasználó egyenlegén a `payout` összeget,
   * beállítja a `processedAt` időpontot,
   * megakadályozza a **kétszeres feldolgozást** (idempotencia‑zár).

## Feladatok

* [ ] **Payout kalkulátor** segédmodul: `cloud_functions/src/tickets/payout.ts` – single/multi ticket kifizetés számítás az `oddsSnapshot` alapján
* [ ] **Idempotencia & lock**: `processedAt` őrszem és `tickets_meta/{ticketId}` lock doksi tranzakción belüli ellenőrzése
* [ ] **match\_finalizer patch**: döntéshozatal → atomikus tranzakció (`runTransaction`) a ticket és a `users/{uid}.balance` frissítésére
* [ ] **Hibakezelés**: részleges hiba esetén a ticket marad `pending`; 401/429/5xx backoff
* [ ] **Teszt** (Functions emulator):

  * all‑won → egyszeri jóváírás
  * mixed (van `void`) → payout helyesen, státusz `won/lost/void` szabályok szerint
  * dupla futtatás → **nem** keletkezik második jóváírás (`processedAt`/lock védi)

## Acceptance Criteria / Done Definition

* [ ] A `cloud_functions` build és jest tesztek **zöldek**
* [ ] Egy ticket **egyszer** kerül feldolgozásra (idempotencia bizonyított teszttel)
* [ ] Payout számítás megfelel a dokumentált képletnek (lásd payout.ts)
* [ ] A kódbázisban nincs OddsAPI‑maradvány ezen folyamat körül

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_finalizer_payout_atomicity.yaml`
* Előzmények: `api_football_backend_cutover_and_oddsapi_removal.md`, `ticket_create_flow_atomic.md`
* Séma: `tickets_schema_and_rules.md`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

A `match_finalizer` megerősítése: **atomikus** státusz‑ és egyenlegfrissítés idempotens védelemmel.

### 🧠 Fejlesztési részletek

* **Payout képlet**: kombinált (szorzatos) ticket: `payout = stake * Π(oddsSnapshot[i])`, `void` tip **odds = 1.0**; vesztes tipp → `payout = 0`, `status = lost`. Egytételes ticketnél ugyanez egyszeres szorzóval.
* **Döntés tip szinten**: 1X2, O/U, BTTS, AH piacokra egyszerű szabályok (alap mapping most; bővítés külön vászonban).
* **Idempotencia**: tranzakcióban vizsgáld a `ticket.processedAt` és a `tickets_meta/{ticketId}.locked` mezőket; ha bármelyik jelzi a feldolgozást, **no‑op**.
* **Tranzakció**: olvasd a `users/{uid}` és a `tickets/{ticketId}` doksikat, számolj, majd írd vissza **egy** tranzakcióban mindkettőt.
* **Batch méretezés**: finalizer ciklus 50–100 ticketen fut körönként; 429 esetén exponenciális backoff.

### 🧪 Tesztállapot

* Jest + Emulator: sikeres payout; duplafutás idempotens; `void` tip kezelése.
* Várható futási idő max 2–3s/ciklus 50 ticket esetén (emuban). Prod metrikák külön vászonban.

### 🌍 Lokalizáció

* Nincs UI‑sztring; a logok angol egységesítése belső célra.

### 📎 Kapcsolódások

* `cloud_functions/src/match_finalizer.ts` – itt történik a patch
* `cloud_functions/src/tickets/payout.ts` – új modul
* `users/{uid}.balance` – tranzakciós mező
