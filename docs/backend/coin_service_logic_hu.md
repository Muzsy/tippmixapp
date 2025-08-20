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

- A `debitAndCreateTicket()` metódus Firestore tranzakciót futtat, amely:
    - beolvassa az aktuális egyenleget a `users/{uid}/wallet.coins` mezőből;
    - ha az egyenleg < tét, `FirebaseException(insufficient_coins)` hibával megszakad;
    - levonja a tétet a `users/{uid}/wallet.coins` mezőből;
    - audit sort ír a `users/{uid}/ledger/{ticketId}` útvonalra;
    - ugyanebben a tranzakcióban létrehozza a `tickets/{ticketId}` dokumentumot.

Ez garantálja az atomitást – a felhasználó nem kerülhet negatív egyenlegbe szelvény nélkül.

### Eredmény kiértékelésekor

- A `CoinService.credit(uid, potentialWin, ticketId)` Firestore tranzakciót futtat, amely:
    - ellenőrzi a `users/{uid}/ledger/{ticketId}` dokumentumot és ha létezik, kilép (idempotens);
    - növeli a `users/{uid}/wallet.coins` mezőt `FieldValue.increment` segítségével;
    - létrehozza a ledger bejegyzést `{ userId, amount, type: 'win', refId: ticketId, source: 'coin_trx', createdAt }`.
- A `CoinService.debit(uid, stake, ticketId)` ugyanezt a folyamatot hajtja végre negatív összeggel és `type: 'bet'` értékkel.

---

## 🧾 Technikai megvalósítási terv

- TippCoin módosítás kizárólag szerveroldalon történhet
- Firebase Cloud Functions használata javasolt
- Minden tranzakció legyen naplózva (`TippCoinLogModel`)
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

- A `CoinService.transact()` idempotens módon frissíti az egyenleget és létrehozza a ledger bejegyzést az új SoT alatt.
- A `CoinService.debitAndCreateTicket()` továbbra is atomikusan levonja a tétet és létrehozza a szelvényt.
  - A wallet egyenleg a `users/{uid}/wallet.coins` mezőn azonnal frissül.
- A `coin_logs` gyűjtemény kivezetésre került, helyette a ledger szolgál naplóként.

---

## 🔒 Codex / CI szabályok

- Minden TippCoin tranzakció legyen teszttel lefedve
- A felhasználó soha ne tudjon kliens oldalon TippCoin-t változtatni
- Firestore security rules tiltsák az önkényes írást

## 📘 Változásnapló

- 2025-08-20: Dokumentálva a user-centrikus wallet és ledger duplairás, valamint a regisztrációs inicializálás.
- 2025-08-20: Frissítve az egyetlen SoT-ra (`users/{uid}/wallet` + `users/{uid}/ledger`), legacy írások megszüntetése.
