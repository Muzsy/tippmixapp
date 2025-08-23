# Cloud Functions – Auth trigger javítás (v1 onCreate)

## Kontextus

A mostani deploy a `cloud_functions/lib/coin_trx.logic.js` betöltésekor hibával leáll:
`TypeError: identity.onUserCreated is not a function` (Firebase Functions v2 identity modulban nincs `onUserCreated`). A projektben minden más már v2‑re van migrálva, viszont az Auth "user created" eseményre ma stabil megoldás a v1 `auth.user().onCreate()` trigger.

## Cél (Goal)

A deploy hibájának megszüntetése úgy, hogy az Auth‑alapú user‑inicializálás (users/{uid} + wallet init + opcionális signup bónusz) változatlanul működjön, miközben a többi funkció marad v2‑ben.

## Feladatok

* [ ] `cloud_functions/coin_trx.logic.ts`: a v2 identity import kiváltása v1 Auth triggerre.
* [ ] Ugyanitt: az `onUserCreate` export átírása `functions.auth.user().onCreate(...)` formára.
* [ ] Build ellenőrzés: `cd cloud_functions && npm ci && npm run build` zöld legyen.
* [ ] Gyors smoke: ellenőrizzük, hogy a buildelt `lib/` már nem hivatkozik `identity.onUserCreated`‑re.

## Acceptance Criteria / Done Definition

* [ ] `firebase deploy --only functions` nem dob `TypeError: identity.onUserCreated is not a function` hibát.
* [ ] Új Auth user létrejöttekor létrejön a `users/{uid}` doc, a `users/{uid}/wallet` (coins: 50) és a signup logika változatlanul lefut.
* [ ] A többi v2 funkció (callable, scheduler, Pub/Sub, Firestore) érintetlenül működik.
* [ ] `cloud_functions/lib/coin_trx.logic.js` nem tartalmaz `identity.onUserCreated` sztringet.

## Hivatkozások

* Canvas → `/codex/goals/CF-Auth-Trigger-Fix—onUserCreate-v1.yaml`
* Referencia: Bonus Engine – Firestore Tárolási Terv (v1), Tippmix App – User‑centrikus Firestore Architektúra.
