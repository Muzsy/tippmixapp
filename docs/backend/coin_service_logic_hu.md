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

- `UserModel.tippCoin = 1000`

### Szelvény beküldésekor

- A `debitAndCreateTicket()` metódus Firestore tranzakciót futtat, amely:
  - beolvassa az aktuális egyenleget a `wallets/{uid}.coins` mezőből;
  - ha az egyenleg < tét, `FirebaseException(insufficient_coins)` hibával megszakad;
  - levonja a tétet mind a `wallets/{uid}.coins`, mind a `users/{uid}.coins` mezőből;
  - ugyanebben a tranzakcióban létrehozza a `tickets/{ticketId}` dokumentumot.

Ez garantálja az atomitást – a felhasználó nem kerülhet negatív egyenlegbe szelvény nélkül.

### Eredmény kiértékelésekor

- Ha a szelvény `won`:

  - Jóváírás: `user.tippCoin += potentialWin`
- Ha `lost`: nincs változás

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

- Naplók: `users/{uid}/coin_logs/` kollekció alatt
- A profil UI-on megjeleníthetők az utolsó tranzakciók

---

## ⚠️ Jelenlegi állapot

- Megvalósult a `CoinService.debitAndCreateTicket()` atomikus levonás és szelvénylétrehozás.
- Az egyenleg azonnal tükröződik a `users/{uid}.coins` és `wallets/{uid}.coins` dokumentumokon.
- A `coin_logs` naplózás még hiányzik.

---

## 🔒 Codex / CI szabályok

- Minden TippCoin tranzakció legyen teszttel lefedve
- A felhasználó soha ne tudjon kliens oldalon TippCoin-t változtatni
- Firestore security rules tiltsák az önkényes írást
