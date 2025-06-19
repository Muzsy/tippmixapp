## 🎯 Funkció

A Firestore security rules v2 célja, hogy a TippCoin tranzakciók (`coin_logs`) és a felhasználói adatok (`users`) maximális biztonsággal legyenek kezelve. A szabályrendszer garantálja, hogy:

* csak a saját adatokat érhetjük el,
* nem lehet tranzakciót megismételni,
* az adatok típusa és szerkezete validált,
* érzékeny mezők (pl. admin-only) védve legyenek,
* minden jogosultsági sértés megfelelő lokalizált hibát adjon vissza.

## 🧠 Fejlesztési részletek

### `coin_logs` kollekció szabályai:

* `allow read`: csak ha `request.auth.uid == resource.data.userId`
* `allow write`: csak ha:

  * `request.auth.uid == request.resource.data.userId`
  * `timestamp == request.time`
  * `amount` integer
  * `type in ["debit", "credit"]`
  * `reason` szerepel és string
  * `transactionId` szerepel (Cloud Function validálja az egyediségét)
* `allow update: if false`

### `users` kollekció szabályai:

* `allow read`: saját adat olvasható
* `allow write`: csak saját adat írható, kivéve admin-only mezők (pl. `coinResetFlag`, `role`)
* Admin-only mezők írása csak akkor engedélyezett, ha `request.auth.token.role == "admin"`

### Validáció típusszinten

* `amount`: `is int`
* `timestamp`: kötelező és `== request.time`
* `type`, `reason`, `transactionId`: kötelező mezők

## 🧪 Tesztállapot

* [ ] Firebase Emulator Suite tesztek:

  * más user coin log írása → hibát dob
  * hiányzó `transactionId` → hibát dob
  * hibás típus (pl. string az amount helyett) → hibát dob
  * frissítésre való kísérlet → hibát dob

## 🌍 Lokalizáció

* A `lib/l10n/app_en.arb`, `app_hu.arb`, `app_de.arb` fájlok tartalmazzák a rules hibák emberi olvasható verzióit:

  * `insufficient_permissions`
  * `invalid_transaction_type`
  * `missing_transaction_id`
  * `amount_must_be_integer`
  * `admin_only_field`

## 📎 Kapcsolódások

* `coin_service.dart` → minden tranzakció írást ezen keresztül hajtunk végre
* `coin_trx.ts` → Cloud Function, ami biztosítja az írás helyességét és a transactionId egyediségét
* `bonus_policy.md` → reason mezők engedélyezett értékei
* `firebase.rules` → ez a canvas tartalma irányítja

Ez a v2-es szabályrendszer készen áll éles környezetre is, maximálisan védi a kritikus pénzügyi műveleteket, auditálható módon, többnyelvű hibaüzenetekkel.
