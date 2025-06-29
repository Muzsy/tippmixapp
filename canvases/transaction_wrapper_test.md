# T15 – Firestore Transaction‑wrapper + Retry (CoinService) integrációs teszt vászon

## Cél

Implementálni egy **TransactionWrapper** osztályt, amely

1. a Firebase Firestore `runTransaction` hívását absztrahálja,
2. **maximum 3 automatikus újrapróbálkozást** végez `FirebaseException/code == "aborted"` vagy `"deadline‑exceeded"` esetén,
3. naplózza a próbálkozások számát `logger.info`,
4. minden **CoinService** debit/credit művelet ezt használja.

A wrapper korrekt futását **integrációs tesztek** igazolják, különösen két egyidejű fogadás (race‑condition) esetén.  fileciteturn5file2

---

## Környezet

* **Dart** (nem Flutter) `test` csomag
* `cloud_firestore_mocks` › `FakeFirebaseFirestore` – network offline, lokális memóriában
* `package:mocktail/mocktail.dart` a logger stuboláshoz
* `TransactionWrapper` konfigurálható: `maxRetries` (default 3), `delayBetweenRetries` (Duration)

```dart
final wrapper = TransactionWrapper(
  firestore: fakeFirestore,
  maxRetries: 3,
  delayBetweenRetries: const Duration(milliseconds: 10),
  logger: fakeLogger,
);
```

---

## Tesztesetek

| ID    | Leírás                                    | Előkészítés                                     | Elvárt eredmény                                              |
| ----- | ----------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| TW-01 | **Sikeres tranzakció 1. próbálkozásra**   | balance=100, debit −20                          | új balance 80, wrapper 1 próbálkozás, log once               |
| TW-02 | **Retry „aborted” → success**             | fakeFirestore.throwNext(code:"aborted")         | 2 próbálkozás után siker, balance helyes                     |
| TW-03 | **Retry „deadline‑exceeded” → success**   | első két runTransaction dobja a kódot, 3. siker | balance helyes, próbálkozás=3                                |
| TW-04 | **MaxRetry exceeded**                     | mindig "aborted"                                | `TooManyAttemptsException`, balance változatlan              |
| TW-05 | **Concurrency – két párhuzamos debit**    | balance=200, két `debit −50` Future.wait        | végbalance 100, egyik sem dob Exception, wrapper nem ütközik |
| TW-06 | **Concurrency – párhuzamos debit+credit** | balance=100, debit −40 + credit +30             | végbalance 90, kronológia független                          |

> **Megjegyzés**: TW‑05 – TW‑06 ugyanarra a FakeFirebaseFirestore példányra futnak párhuzamosan. A wrapper tranzakciós zárolása biztosítja a konzisztenciát.

---

## DoD

* Modell + wrapper + módosított CoinService kód **dart analyze** tiszta.
* Fenti 6 integrációs teszt **zöld** (`dart run test`).
* Wrapper loggolja a próbálkozásokat (mocktail verify).
* Coverage a `transaction_wrapper.dart`‑ra ≥ 90 %.
* Nincs valós Firestore network call.

---

## Nyitott kérdések

1. `delayBetweenRetries` fix vagy konfigurálható ENV‑ben? (tuning load‑testekhez)
2. Logger formátum: `logger.info('[TransactionWrapper] attempt $i')` megfelel?
3. CoinService concurrency limit szükséges CLI oldalon is? (külön scope)

---

## Hivatkozások / Inputs

* `lib/services/coin_service.dart` – debit/credit hívások
* **ÚJ** `lib/utils/transaction_wrapper.dart` – ebben a sprintben jön létre
* `pubspec.yaml` → add `cloud_firestore_mocks`, `mocktail`, `logger`
* `testing_guidelines.md` – retry, fake Firestore, log assert szabályok
