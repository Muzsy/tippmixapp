# T14 – TippCoinLogModel implementáció + unit‑/integrációs teszt vászon

## Cél

A **TippCoinLogModel** bevezetése a pénzügyi tranzakciónapló (Firestore **`coin_logs`** kollekció) számára, valamint a modellhez tartozó teljes körű tesztelés.

Sprint5 DoD kitétel: *„Log rekord minden debit/creditnél”* fileciteturn4file3.

---

## Adatstruktúra (javasolt)

| Field       | Type                   | Kötelező | Megjegyzés                             |
| ----------- | ---------------------- | -------- | -------------------------------------- |
| `id`        | `String`               | Igen     | Firestore‑doc ID (UUID v4)             |
| `userId`    | `String`               | Igen     | Auth UID                               |
| `amount`    | `int`                  | Igen     | + = credit, − = debit (TippCoin)       |
| `type`      | `String` (enum)        | Igen     | `bet`, `deposit`, `withdraw`, `adjust` |
| `timestamp` | `DateTime`             | Igen     | ServerTimestamp amikor logoljuk        |
| `txId`      | `String?`              | Nem      | Kapcsolódó Firestore transaction ID    |
| `meta`      | `Map<String,dynamic>?` | Nem      | Szabadon bővíthető extra adat          |

---

## Firestore‑útvonal

`/coin_logs/{id}` – ***nincs*** nested subcollection; a lekérdezés `where('userId', isEqualTo: uid)` + `orderBy('timestamp', descending: true)`.

---

## Implementációs lépések

1. **`lib/models/tippcoin_log_model.dart`** új fájl:

   * `class TippCoinLogModel` with `fromJson` / `toJson` / `copyWith` / equatable.
   * Gyári konstruktőr `TippCoinLogModel.newDebit(...)`, `newCredit(...)`.
   * Statikus `collection` getter (Firestore reference) – **NE** hívjon valódi Firestore‑t teszt közben.
2. **`lib/services/tippcoin_log_service.dart`** (mini wrapper): `logDebit`, `logCredit` → `add` a kollekcióhoz. (A T15 transaction‑wrapper fogja majd override‑olni.)
3. **Null‑safety, code‑coverage target ≥ 90 %.**

---

## Tesztesetek

### Unit (Model)

| ID    | Leírás                         | Előkészítés    | Elvárt                         |
| ----- | ------------------------------ | -------------- | ------------------------------ |
| TM‑01 | **fromJson / toJson**          | példa‐map      | roundtrip ugyanazt adja vissza |
| TM‑02 | **Positive / negative amount** | +100 / −50     | `amount` értéke megmarad       |
| TM‑03 | **Enum validation**            | invalid `type` | `FormatException` dob          |

### Integration (Service + Fake Firestore)

| ID    | Leírás                | Futtatás                 | Elvárt                        |
| ----- | --------------------- | ------------------------ | ----------------------------- |
| TI‑01 | **logCredit ír**      | `logCredit(+200)`        | doc létrejön, `amount == 200` |
| TI‑02 | **logDebit ír**       | `logDebit(−75)`          | doc létrejön, `amount == -75` |
| TI‑03 | **Auto‑ID egyediség** | két egymást követő hívás | két különböző `id`            |

> **Megjegyzés**: Integration teszt fake Firestore‑ral (`cloud_firestore_mocks`). E2E concurrency lock a T15‑ben kerül tesztelésre → itt *skip*.

---

## DoD

* Modell + service kód **build** + **dart analyze** hibamentes.
* 3 unit + 3 integration teszt **zöld** CI‑ben (`dart run test`).
* Code‑coverage (model + service) ≥ 90 %.
* Nincs `debugPrint`, Firestore offline mock fut.
* Canvas + YAML lint tiszta.

---

## Kapcsolódások (inputs)

* cloud\_firestore\_mocks – `pubspec.yaml` dev\_dependency
* lib/services/coin\_service.dart (meglévő debit/credit hívások) – log‑hívásokat ide illesztjük future PR‑ban.
* Testing Guidelines – faker szabályok ✔
* Sprint4 Audit: tranzakció‑napló risk fileciteturn4file15

---

## Nyitott kérdések

1. `txId` mező használata: csak Firestore transaction wrapper tölti? (T15)
2. `meta` struktúra – JSON‑serializable nested map engedélyezett?
3. Concurrency test coverage ide kerüljön vagy T15‑re?

---

## Prioritás

**P1 (backend)** – jelen sprintben kritikus pénzügyi integritási követelmény.

---

## Következő lépés

YAML‑cél (`codex/goals/fill_canvas_tippcoin_log_model.yaml`) létrehozása, amely:

* bemenetként megadja a fenti forrás‑/teszt‑fájlokat,
* két lépést definiál: **generate\_model\_code**, **generate\_model\_tests**,
* `run_tests: false`.
