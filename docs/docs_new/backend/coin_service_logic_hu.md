# 🪙 CoinService logika (HU)

Ez a dokumentum leírja a TippmixApp-ban használt TippCoin virtuális valuta működését és tervezett üzleti logikáját.
A TippCoin a fogadások tétje és a jutalmazás alapja.

---

## 🎯 Célja

* Virtuális alkalmazáson belüli valuta (nem valódi pénz)
* Fogadási tétként használatos
* Nyereményként adható
* Eredmények és badge-ek feloldására is szolgálhat (terv)

---

## 🧠 Tervezett működés

### Regisztrációkor

* `UserModel.tippCoin = 1000`

### Szelvény beküldésekor

* Levonás: `user.tippCoin -= stake`
* Ha nincs elég egyenleg → blokkolás

### Eredmény kiértékelésekor

* Ha a szelvény `won`:

  * Jóváírás: `user.tippCoin += potentialWin`
* Ha `lost`: nincs változás

---

## 🧾 Technikai megvalósítási terv

* TippCoin módosítás kizárólag szerveroldalon történhet
* Firebase Cloud Functions használata javasolt
* Minden tranzakció legyen naplózva (`TippCoinLogModel`)

```json
TippCoinLog {
  type: "stake" | "reward",
  amount: int,
  relatedTicketId: string,
  createdAt: timestamp
}
```

* Naplók: `users/{uid}/coin_logs/` kollekció alatt
* A profil UI-on megjeleníthetők az utolsó tranzakciók

---

## ⚠️ Jelenlegi állapot

* Csak statikus TippCoin mező van a UserModel-ben
* Nincs CoinService osztály vagy logika
* Nincs log kollekció vagy UI komponens

---

## 🔒 Codex / CI szabályok

* Minden TippCoin tranzakció legyen teszttel lefedve
* A felhasználó soha ne tudjon kliens oldalon TippCoin-t változtatni
* Firestore security rules tiltsák az önkényes írást
