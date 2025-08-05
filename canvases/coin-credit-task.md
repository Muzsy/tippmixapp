# Wallet tranzakciók – **coin-credit-task**

## Kontextus

A *match\_finalizer* már hívja a `CoinService.credit(uid, amount)` metódust, de annak jelenlegi implementációja egy egyszerű `FieldValue.increment` – ez **nem véd az idempotens jóváírás** és dupla–spend ellen.

### Követelmények

1. **Idempotencia**: ugyanarra a ticketId-re (vagy transactionId-re) egy nyeremény csak egyszer íródhat jóvá, akkor is, ha a Cloud Function újrapróbál (exactly‑once semantics).
2. **ACID tranzakció** Firestore-ban, hogy a wallet balance és a ledger/receipt együtt frissüljön.
3. **Szerver‑oldali biztonság**: a kliens sose írhat közvetlenül a wallets doksira.

### Javasolt adatmodell

```
wallets/{uid}
  • balance: number
  • updatedAt: timestamp
wallets/{uid}/ledger/{ticketId}
  • amount: number (pozitív = jóváírás, negatív = tétlevonás)
  • type: 'bet' | 'win'
  • createdAt: timestamp
```

*Primary key* a ledger-en a **ticketId**, így a `ledger.doc(ticketId)` egyszeri írása garantálja az idempotenciát.

## Feladatok

* [ ] **CoinService.credit(uid, amount, ticketId)** – Firestore tranzakció:

  1. Ellenőrzi, létezik‑e `ledger/{ticketId}`.
  2. Ha nem, `increment(amount)` a balance-on és létrehozza a ledger-dokumentumot.
  3. Ha már létezik, logol és kilép (idempotens).
* [ ] **CoinService.debit(uid, amount, ticketId)** – hasonló, negatív amount; (későbbi beküldéskor hasznos).
* [ ] **Unit-tesztek**:

  * `credits only once even if called twice in parallel` (Promise.all)
  * `balance updated correctly`
  * `ledger doc created`.
* [ ] **Security Rules**: frissítsd a test.rules/ firestore.rules fájlt – `wallets` kollekció **csak** Cloud Functions írhatja.

## Acceptance Criteria

* Jest-teszt zöld (emulator).
* Párhuzamos hívásnál is egyszeres jóváírás.
* Firestore.rules deploy lefut.

## Függőségek

* *match-finalizer-task* (a credit hívás már benne van).
