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
    - ellenőrzi a `users/{uid}/ledger/{ticketId}` dokumentumot és ha létezik, kilép (idempotens); ilyenkor a wallet növelése kimarad.
    - növeli a `users/{uid}/wallet.coins` mezőt `FieldValue.increment` segítségével;
    - létrehozza a ledger bejegyzést `{ userId, amount, type: 'win', refId: ticketId, source: 'coin_trx', createdAt }`.
- A `CoinService.debit(uid, stake, ticketId)` ugyanezt a folyamatot hajtja végre negatív összeggel és `type: 'bet'` értékkel.

### Napi bónusz jóváírás

- A `daily_bonus` időzített Cloud Function felhasználónként **50** coint ír jóvá.
- A felhasználók a `claim_daily_bonus` callable függvénnyel is igényelhetik a napi bónuszt, amely beolvassa a `system_configs/bonus_rules` dokumentumot, és `CoinService.credit(uid, amount, refId, 'daily_bonus', t, before)` hívással könyvel.
- A jóváírás determinisztikus `refId` (`bonus:daily:YYYYMMDD`) alapján történik az idempotencia érdekében.
- Az időzített feladat 200‑as lapokban iterál a felhasználókon, és `firebase-functions/logger` segítségével naplózza az előrehaladást.

---

## 🧾 Technikai megvalósítási terv

- TippCoin módosítás kizárólag szerveroldalon, Cloud Functionökön keresztül történhet.
- A kliens nem módosítja közvetlenül a `users/{uid}/wallet` vagy `users/{uid}/ledger` útvonalakat.
- Minden tranzakció legyen naplózva idempotens `refId` mezővel.
- Összetett Firestore index: `collectionGroup('ledger')` `(type ASC, createdAt DESC)` mezőkre.
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
    checksum: string // SHA1(uid:type:refId:amount)
    createdAt: timestamp
  ```

- Legacy `wallets/*` csak olvasásra marad, a `coin_logs/*` gyűjtemény megszűnt
- A profil UI-on megjeleníthetők az utolsó tranzakciók

---

## ⚠️ Jelenlegi állapot

- A `CoinService.debitCoin` és `creditCoin` csak a `coin_trx` függvényt hívja; minden wallet módosítás szerveroldalon zajlik.
- A `CoinService.debitAndCreateTicket()` létrehozza a szelvényt, majd `coin_trx` segítségével vonja le a tétet.
- A wallet egyenleg forrása a `users/{uid}/wallet.coins`, melyet Cloud Function frissít.
- A `coin_logs` gyűjtemény teljesen kivezetésre került, a ledger az egyetlen napló.
- A regisztrációs és napi bónusz igénylését a `system_configs/bonus_rules` szabályozza.

---

## 🔒 Codex / CI szabályok

- Minden TippCoin tranzakció legyen teszttel lefedve
- A felhasználó soha ne tudjon kliens oldalon TippCoin-t változtatni
- Firestore security rules tiltsák az önkényes írást

## 📘 Változásnapló

- 2025-08-20: Dokumentálva a user-centrikus wallet és ledger duplairás, valamint a regisztrációs inicializálás.
- 2025-08-20: Frissítve az egyetlen SoT-ra (`users/{uid}/wallet` + `users/{uid}/ledger`), legacy írások megszüntetése.
- 2025-08-20: Kivezetve a kliens oldali wallet írás; a `coin_trx` végzi az összes egyenlegváltozást.
- 2025-08-21: Dokumentálva a napi bónusz jóváírás CoinService használatával és dátum alapú `refId`-val.
- 2025-08-22: Bevezetve a ledger `checksum` mező és a `claim_daily_bonus` callable; regisztrációs bónusz CF-ből kezelve.
- 2025-10-02: Hozzáadva a lapozott napi bónusz strukturált logolással és a ledger `type+createdAt` index.
- 2025-10-03: Bevezetve a ledger előzetes ellenőrzése, így meglévő bejegyzésnél a wallet növelése kimarad.
