# API‑Football átállás – Emulatoros end‑to‑end ticket flow (P0)

## Kontextus

Az OddsAPI → API‑Football átállás fő komponensei elkészültek (backend provider, frontend service, ticket create/finalizer/payout, odds drift). A még hiányzó P0 feladat: a **teljes szelvény‑életciklus** végponttól végpontig történő, emulátoros ellenőrzése – valódi Firebase emulátorral és API‑Football mockolt válaszokkal.

## Cél (Goal)

Automatizált **E2E teszt**: *create → finalize → payout* flow Functions emulátorban, amely validálja a tranzakciós írásokat (stake levonás, idempotencia, processedAt őrszem) és a státusz/payout helyes számítását API‑Football sémán.

## Feladatok

* [ ] **Functions emu setup**: Jest/E2E futtatás Firebase Emulators‑szal (Firestore + Auth).
* [ ] **API‑Football mock**: determinisztikus mintaválaszok a `fixtures`/score lekérésekhez (lokális json).
* [ ] **Seed**: felhasználó (`users/{uid}.balance`) és mintatippek/fixtureId‑k előkészítése.
* [ ] **CreateTicket hívás**: callable `create_ticket.ts` meghívása idempotencyKey‑jel, *oddsSnapshot* és *kickoff* valid mintákkal.
* [ ] **Finalizer futtatás**: `match_finalizer` invokáció; döntés: `won|lost|void`.
* [ ] **Payout ellenőrzés**: `tickets/{ticketId}.status/payout` és `users/{uid}.balance` tranzakciósan frissült.
* [ ] **Idempotencia teszt**: finalizer kétszeri futtatása → másodjára no‑op (existing `processedAt`).
* [ ] **CLI parancsok**: `npm test` (functions), `flutter analyze` + `flutter test` (app) zöld.
* [ ] **Dokumentáció**: rövid futtatási jegyzet `/docs/e2e_ticket_flow_emulator.md`.

## Acceptance Criteria / Done Definition

* [ ] E2E jest teszt **zöld**: create → finalize → payout, és idempotens finalizer.
* [ ] `users.balance` változik **csak egyszer**, a második finalizer futás **nem** ír.
* [ ] `tickets.status` és `payout` a `payout.ts` szabályai szerint számolódik (void=1.0, lost→0).
* [ ] **Nincs** külső hálózati hívás: az API‑Football válaszok **mockból** jönnek.
* [ ] `flutter analyze` hibamentes, `flutter test` zöld (drift dialog + i18n widget tesztek is).
* [ ] Futási jegyzet elérhető a `/docs` alatt.

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_emulator_e2e_ticket_flow.yaml`
* Kapcsolódó canvacok: `ticket_create_flow_atomic.md`, `finalizer_payout_atomicity.md`, `odds_drift_prompt_frontend.md`
* Dokumentáció: `Codex Canvas Yaml Guide.pdf`, `Api Football Migration Plan.pdf`
