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

- Cloud Function inicializálja a `users/{uid}` és `users/{uid}/wallet` dokumentumot **50** coin kezdő egyenleggel

### Szelvény beküldésekor

- A `debitAndCreateTicket()` metódus Firestore tranzakciót futtat, amely:
    - beolvassa az aktuális egyenleget a `wallets/{uid}.coins` mezőből;
    - ha az egyenleg < tét, `FirebaseException(insufficient_coins)` hibával megszakad;
    - levonja a tétet mind a `wallets/{uid}.coins`, mind a `users/{uid}.coins` mezőből;
    - tükrözi a változást a `users/{uid}/wallet` dokumentumba és audit sort ír a `users/{uid}/ledger/{ticketId}` útvonalra;
    - ugyanebben a tranzakcióban létrehozza a `tickets/{ticketId}` dokumentumot.

Ez garantálja az atomitást – a felhasználó nem kerülhet negatív egyenlegbe szelvény nélkül.

### Eredmény kiértékelésekor

- A `CoinService.credit(uid, potentialWin, ticketId)` Firestore tranzakciót futtat, amely:
    - ellenőrzi a `wallets/{uid}/ledger/{ticketId}` dokumentumot és ha létezik, kilép (idempotens);
    - növeli a `wallets/{uid}.balance` mezőt és tükrözi `users/{uid}/wallet` dokumentumba `FieldValue.increment` használatával;
    - létrehozza a ledger bejegyzést `{ amount, type: 'win', createdAt }` és tükrözi a `users/{uid}/ledger/{ticketId}` útvonalra.
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
   wallets/{uid}
     balance: number
     updatedAt: timestamp
     ledger/{ticketId}
       amount: number
       type: 'bet' | 'win'
       createdAt: timestamp
  users/{uid}/wallet (tükör)
    coins: number
    updatedAt: timestamp
  users/{uid}/ledger/{ticketId} (tükör)
    amount: number
    type: 'bet' | 'win'
    createdAt: timestamp
   ```

- Naplók: `users/{uid}/coin_logs/` kollekció alatt
- A profil UI-on megjeleníthetők az utolsó tranzakciók

---

## ⚠️ Jelenlegi állapot

- A `CoinService.transact()` idempotens módon frissíti az egyenleget és létrehozza a ledger bejegyzést.
- A `CoinService.debitAndCreateTicket()` továbbra is atomikusan levonja a tétet és létrehozza a szelvényt.
  - A wallet egyenleg a `wallets/{uid}.balance` mezőn azonnal frissül és tükröződik a `users/{uid}/wallet` dokumentumba.
- A `coin_logs` naplózás még hiányzik.

---

## 🔒 Codex / CI szabályok

- Minden TippCoin tranzakció legyen teszttel lefedve
- A felhasználó soha ne tudjon kliens oldalon TippCoin-t változtatni
- Firestore security rules tiltsák az önkényes írást

## 📘 Változásnapló

- 2025-08-20: Dokumentálva a user-centrikus wallet és ledger duplairás, valamint a regisztrációs inicializálás.
