# Backend – Firestore Rules hotfix – Ticket create permission

## Kontextus

A felhasználók *cloud\_firestore/permission‑denied* hibát kapnak, amikor szelvényt (ticket) próbálnak beküldeni. A futási log és a security\_rules.test `SR‑13` tesztje alapján a `/tickets/{ticketId}` szabály a `request.resource.data.keys().hasOnly([...])` listából **hiányolja** a `tips` és `stake` kulcsokat. A `Ticket` modell viszont ezeket kötelezően tartalmazza, így a Firestore szabályok elutasítják a `create` műveletet.

## Cél (Goal)

Az authenticated felhasználó problémamentesen tudjon saját szelvényt létrehozni, miközben a többi biztonsági feltétel érintetlen marad.

## Feladatok

* [ ] Frissítsük a `firebase.rules` fájlban a `/tickets/{ticketId}` alatt lévő `allow create` feltételt úgy, hogy a `hasOnly([...])` listába bekerüljön a **`'tips'`** és **`'stake'`** kulcs.
* [ ] Ne módosítsunk egyéb szabályt (read/update/delete marad, csak a kulcslista bővül).
* [ ] Futtassuk a `scripts/test_firebase_rules.sh` szkriptet; a `SR‑13 tickets create` tesztnek zöldre kell váltania.
* [ ] Futtassuk a `flutter analyze` parancsot – nem lehet lint vagy warning.

## Acceptance Criteria / Done Definition

* [ ] A TippmixApp‑ban a szelvény beküldése már nem dob *permission‑denied* hibát.
* [ ] A CI‑ben a **Firebase security rules** teszt (`scripts/test_firebase_rules.sh`) teljesen zöld.
* [ ] `flutter analyze` hibamentes.
* [ ] Tesztlefedettség ≥ 80 % változatlan marad.

## Hivatkozások

* Canvas → `/codex/goals/fix_ticket_permission_denied.yaml`
* Log részlet: lásd *log.txt* turn0file0 SR‑13 teszt kimenet.
