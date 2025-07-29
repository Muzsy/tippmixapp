# Sprint 13 – Felhasználónév (nickname) egyediség ellenőrzése Cloud Functions nélkül

## Kontextus

A regisztráció 2. lépésén a becenév egyediségét a `AuthService.validateNicknameUnique()` Cloud Function (`checkNicknameUnique`) ellenőrzi. Lokalizált teszt‑ vagy debug környezetben a Function gyakran **App Check 403** hibával tér vissza, ezért a flow is beragad.

* Érintett fájl: `lib/services/auth_service.dart`
* Érintett UI: `lib/screens/register_step2_form.dart`

## Cél

* Számoljuk fel a Cloud Functions függőséget.
* Ellenőrizzük a nickname‑et **közvetlenül Firestore‑ból** (`profiles` collection, indexelt `nickname` field) → `isEmpty == true` ⇒ szabad.
* Offline / hiba esetén *fail‑open* (→ `true`) ugyanúgy, mint e‑mail validációnál.

## Feladatok

1. **`AuthService.validateNicknameUnique()` refaktor**

   * Távolítsuk el a `FirebaseFunctions` hivást és az importot.
   * Adjunk hozzá `cloud_firestore` importot, és query `await FirebaseFirestore.instance.collection('profiles').where('nickname', isEqualTo: nickname).limit(1).get()`.
   * Válasz → `snapshot.docs.isEmpty`.
2. **Unit‑teszt** – mockoljunk Firestore‑t, üres ↔ foglalt dokumentum.
3. **Widget‑teszt** – `register_step2_form.dart`‑ban foglalt név esetén jelenjen meg *errorText*.
4. **Integration‑teszt** – Emulátor: foglalt név → SnackBar, egyedi név → lapoz Step 3‑ra.
5. **CI** – `flutter analyze` + tesztek zöld.

## Acceptance Criteria

* A regisztráció 2. lépése **nem** hív Cloud Functions‑t.
* App Check 403 hiba eltűnik.
* Foglalt becenév esetén hibaüzenet, egyedi név esetén sikeres lapozás.

## Hivatkozások

Canvas → `/codex/goals/sprint13_nickname_unique_firestore.yaml`
Érintett fájlok: `lib/services/auth_service.dart`, `lib/screens/register_step2_form.dart`
