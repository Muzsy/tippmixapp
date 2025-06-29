# T16 – Firestore Security Rules bővítése (coin\_logs, badges, rewards)

## Cél

Megerősíteni a Firestore biztonsági szabályokat, hogy megfeleljenek az újonnan bevezetett **coin\_logs** kollekciónak, és általánosítsuk a **badges**, **rewards**, **notifications** kollekciókhoz. A szabályokat **testemulator**-ral lefedő tesztek igazolják.

---

## Új/Frissített kollekciók & szabályok

| Gyűjtés                          | Művelet                             | Feltétel                                                                                                                                                                                                                                         |
| -------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/coin_logs/{id}`                | **create**                          | request.auth.uid != null && request.resource.data.userId == request.auth.uid && request.resource.data.amount is int && request.resource.data.timestamp == request.time && (request.resource.data.type in \['bet','deposit','withdraw','adjust']) |
|                                  | **read**                            | request.auth.uid != null && resource.data.userId == request.auth.uid                                                                                                                                                                             |
|                                  | **update/delete**                   | false                                                                                                                                                                                                                                            |
| `/badges/{id}`                   | **read**                            | authenticated                                                                                                                                                                                                                                    |
|                                  | **update** userBadges subcollection | request.auth.uid == resource.data.ownerId                                                                                                                                                                                                        |
| `/rewards/{id}`                  | **read**                            | true (public)                                                                                                                                                                                                                                    |
| `/notifications/{uid}/{notifId}` | **read**                            | request.auth.uid == uid                                                                                                                                                                                                                          |
|                                  | **write** (markRead)                | request.auth.uid == uid && request.resource.data.read == true                                                                                                                                                                                    |

> **Megjegyzés:** A **coin\_logs** dokumentumot csak a backend (Cloud Function) írhatná ideálisan, de jelenleg a mobil app logol – ezért a create engedélyezett a kliensnek is, szigorú field‑validációval.

---

## security.rules

Az új szabályok a **firestore.rules** fájlban frissítendők.

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // coin_logs
    match /coin_logs/{logId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid &&
                    request.resource.data.amount is int &&
                    request.resource.data.timestamp == request.time &&
                    request.resource.data.type in ['bet', 'deposit', 'withdraw', 'adjust'];
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow update, delete: if false;
    }
    // existing collections shortened...
  }
}
```

---

## Tesztesetek (Rules Emulator)

| ID    | Leírás                                | Művelet                                            | Eredmény |
| ----- | ------------------------------------- | -------------------------------------------------- | -------- |
| SR-01 | **coin\_logs create saját uid OK**    | create `/coin_logs/abc` user1                      | Allow    |
| SR-02 | **coin\_logs create más uid FAIL**    | create `/coin_logs/xyz` user1, body.userId = user2 | Deny     |
| SR-03 | **coin\_logs read saját uid OK**      | get `/coin_logs/id1` as user1                      | Allow    |
| SR-04 | **coin\_logs read más uid FAIL**      | get `/coin_logs/id2` as user1, owner=user2         | Deny     |
| SR-05 | **coin\_logs update tiltott**         | update `/coin_logs/id1` user1                      | Deny     |
| SR-06 | **badge read publikus**               | get `/badges/b1` unauthenticated                   | Allow    |
| SR-07 | **notification read saját**           | get `/notifications/user1/n1` as user1             | Allow    |
| SR-08 | **notification read idegen**          | get `/notifications/user2/n1` as user1             | Deny     |
| SR-09 | **notification markRead saját**       | update read=true `/notifications/user1/n1` user1   | Allow    |
| SR-10 | **notification markRead idegen FAIL** | update `/notifications/user2/n2` user1             | Deny     |

---

## DoD

* `firestore.rules` frissítve + CI `firebase emulators:exec` script fut.
* 10 rules-teszt zöld (allow/deny) a **security\_rules\_test.dart** fájlban.
* Nincs public write sehol.
* Audit‑tool (Firebase Security Rules Coverage) nem mutat pirosat.

---

## Teszt‑környezet

* **firebase\_test\_lab** vagy `@firebase/rules-unit-testing` npm csomag → shell script a CI‑ben.
* Dart wrapper teszt: `package:cloud_firestore/cloud_firestore.dart` + `package:firebase_rules_test` (ha rendelkezésre áll), különben JS test‑lab container.

---

## Nyitott kérdések

1. A mobil log‑írás hosszú távon marad? Ha átkerül Cloud Function‑re, a `create` engedély CLI‑nél felülvizsgálandó.
2. `timestamp == request.time` feltétel vs. `resource.data.timestamp <= request.time + 1s` lazítás hibahatárra?
3. Badge update jogosultságot pontosítani: owner vagy admin?

---

## Prioritás

**P1** – pénzügyi és adatvédelmi integritás nélkül nem release‑elhető.

---

## Következő lépés

YAML‑cél (`codex/goals/fill_canvas_security_rules.yaml`) létrehozása, amely:

* `firestore.rules` update step;
* `security_rules_test.dart` generálása a 10 tesztesettel (FakeFirebaseEmulator driver);
* `run_tests: false`.
