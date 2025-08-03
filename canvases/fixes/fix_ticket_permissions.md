# Security Rules – Ticket beküldés javítása

## Kontextus

A felhasználók **PERMISSION\_DENIED** hibát kapnak, amikor új szelvényt (ticketet) próbálnak beküldeni, mert a `firebase.rules` fájlban a `/tickets/{ticketId}` `create` szabály `hasOnly()` kulcslistája hibás (ellipszisre vágott), így a beküldött dokumentum nem felel meg a validációnak.  Emellett a kliens lekérdezi a `users/{userId}/settings/{settingId}` útvonalat (pl. „theme”), amelyhez jelenleg nincs szabály, ezért a bejelentkezett felhasználó olvasása is PERMISSION\_DENIED‑del elbukik.

## Cél (Goal)

* A bejelentkezett felhasználó sikeresen tudjon új szelvényt létrehozni.
* A felhasználó gond nélkül olvashassa/írhassa a saját `settings` alkollekcióját.

## Feladatok

* [ ] **firebase.rules** frissítése

  * `/tickets/{ticketId}` kulcslista javítása: `["id","userId","tips","stake","totalOdd","potentialWin","createdAt","updatedAt","status"]`.
  * Új `match /users/{userId}/settings/{settingId}` blokk, `read, write` engedélyezése, ha `isOwner(userId)`.
* [ ] **security\_rules.test.mjs** bővítése

  * Sikeres ticket‑létrehozás teszt
  * Sikeres settings read/write teszt
* [ ] `npm run test:security` futtatása a CI‑ben
* [ ] `firebase deploy --only firestore:rules` zölden lefut

## Acceptance Criteria / Done Definition

* [ ] `flutter analyze` hibamentes
* [ ] Minden Security Rules teszt zöld
* [ ] Új szelvény beküldése bejelentkezve sikeres (emulátorban és prodban)
* [ ] A felhasználó tudja olvasni/írni a `users/<uid>/settings` dokumentumait

## Hivatkozások

* Canvas → `/codex/goals/fix_ticket_permissions.yaml`
* Futási log ➜ PERMISSION\_DENIED (`tickets/...`, `users/.../settings/theme`)
