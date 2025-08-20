# 🪙 CoinService logika (HU)

Ez a dokumentum leírja a TippmixApp-ban használt TippCoin virtuális valuta működését és tervezett üzleti logikáját.
A TippCoin a fogadások tétje és a jutalmazás alapja.

---

## 🎯 Célja

- Virtuális alkalmazáson belüli valuta (nem valódi pénz)
- Fogadási tétként használatos
- Nyereményként adható
- Eredmények és badge-ek feloldására is szolgálhat (terv)

---

## 🧠 Tervezett működés

### Regisztrációkor

- Cloud Function létrehozza a `users/{uid}/wallet` dokumentumot **50** coin kezdő egyenleggel (a felhasználói doksi nem tartalmaz `coins` mezőt)

### Szelvény beküldésekor

- A `debitAndCreateTicket()` először létrehozza a szelvényt a
  `users/{uid}/tickets/{ticketId}` útvonalon.
- Ezután meghívja a `coin_trx` Cloud Functiont a
  `{ amount: stake, type: 'debit', reason: 'bet', transactionId: ticketId }`
  paraméterekkel.
- A Cloud Function levonja az egyenleget a
  `users/{uid}/wallet.coins` mezőből és létrehoz egy ledger sort
  `users/{uid}/ledger/{ticketId}` alatt atomikusan.
- Ha a függvényhívás elbukik, a kliens törli a létrehozott szelvényt
  és továbbdobja a hibát.

Így a kliens soha nem ír közvetlenül a walletre.

### Eredmény kiértékelésekor

- A `CoinService.credit(uid, potentialWin, ticketId)` Firestore tranzakciót futtat, amely:
    - ellenőrzi a `users/{uid}/ledger/{ticketId}` dokumentumot és ha létezik, kilép (idempotens);
    - növeli a `users/{uid}/wallet.coins` mezőt `FieldValue.increment` segítségével;
    - létrehozza a ledger bejegyzést `{ userId, amount, type: 'win', refId: ticketId, source: 'coin_trx', createdAt }`.
- A `CoinService.debit(uid, stake, ticketId)` ugyanezt a folyamatot hajtja végre negatív összeggel és `type: 'bet'` értékkel.

---

## 🧾 Technikai megvalósítási terv

- TippCoin módosítás kizárólag szerveroldalon, Cloud Functionökön keresztül történhet.
- A kliens nem módosítja közvetlenül a `users/{uid}/wallet` vagy `users/{uid}/ledger` útvonalakat.
- Minden tranzakció legyen naplózva idempotens `refId` mezővel.
```json
TippCoinLog {
  type: "stake" | "reward",
  amount: int,
  relatedTicketId: string,
  createdAt: timestamp
}
```

- Wallet struktúra:

  ```
  users/{uid}/wallet
    coins: number
    updatedAt: timestamp
  users/{uid}/ledger/{ticketId}
    userId: string
    amount: number
    type: 'bet' | 'win'
    refId: string
    source: 'coin_trx' | 'log_coin'
    createdAt: timestamp
  ```

- Legacy `wallets/*` és `coin_logs/*` csak olvasásra marad
- A profil UI-on megjeleníthetők az utolsó tranzakciók

---

## ⚠️ Jelenlegi állapot

- A `CoinService.debitCoin` és `creditCoin` csak a `coin_trx` függvényt hívja; minden wallet módosítás szerveroldalon zajlik.
- A `CoinService.debitAndCreateTicket()` létrehozza a szelvényt, majd `coin_trx` segítségével vonja le a tétet.
- A wallet egyenleg forrása a `users/{uid}/wallet.coins`, melyet Cloud Function frissít.
- A `coin_logs` gyűjtemény továbbra is kivezetett, helyette a ledger szolgál naplóként.

---

## 🔒 Codex / CI szabályok

- Minden TippCoin tranzakció legyen teszttel lefedve
- A felhasználó soha ne tudjon kliens oldalon TippCoin-t változtatni
- Firestore security rules tiltsák az önkényes írást

## 📘 Változásnapló

- 2025-08-20: Dokumentálva a user-centrikus wallet és ledger duplairás, valamint a regisztrációs inicializálás.
- 2025-08-20: Frissítve az egyetlen SoT-ra (`users/{uid}/wallet` + `users/{uid}/ledger`), legacy írások megszüntetése.
- 2025-08-20: Kivezetve a kliens oldali wallet írás; a `coin_trx` végzi az összes egyenlegváltozást.
