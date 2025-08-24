# Wallet & Ledger – Cloud Functions enforcement

## 🎯 Funkció

A szelvény beküldésekor a TippCoin terhelés **mindig** a Cloud Functions `coin_trx` callable‑en fusson (EU régió, v2), és a kliens **semmilyen** körülmények között ne írjon a régi, gyökér `wallets/{uid}` ágra. Ha mégis aktiválódna a kliens‑oldali fallback, az is a **user‑centrikus SoT** útvonalra írjon:
`users/{uid}/wallet (doc: 'main')` + `users/{uid}/ledger/{transactionId}`.

## 🧠 Fejlesztési részletek

* A jelenlegi `BetSlipService.submitTicket(...)` lokálisan példányosítja a `CoinService`‑t **`functions` nélkül**, ezért a `CoinService._callCoinTrx()` **fallbackra** esik, és a `_applyLedger(...)` a **legacy** `wallets/{uid}` pathra ír.
* Javítás:

  1. `BetSlipService`: **mindig** `CoinService.live(...)` példányt használjon → `_functions` beállva az `europe-central2` régióra, callable fut.
  2. `CoinService._applyLedger(...)`: a legacy pathot kivezetjük → ha bármikor (pl. teszt/emulátor) mégis fallback aktiválódik, **ugyanarra a SoT‑ra** írjon, mint a CF:
     `users/{uid}/wallet/main` + `users/{uid}/ledger/{transactionId}`.

## 🧪 Tesztállapot

* Minimális regresszió (emulátorral):

  * Sikeres ticket beküldés → **coin\_trx** callable hívása (logban látszik), `users/{uid}/ledger/{ticketId}` új sor (type: `bet` vagy `debit`), és a `users/{uid}/wallet/main.coins` csökken.
  * Nincs írás a `wallets/{uid}` régi ágra (ellenőrzés: üres marad).
* `flutter analyze` hibamentes.
* Meglévő widget/unit tesztek változatlanul futnak.

## 🌍 Lokalizáció

* Nincs új szöveg, ARB változtatás **nem szükséges**.

## 📎 Kapcsolódások

* Összhangban a következő dokumentumokkal:
  – *Tippmix App – User‑centrikus Firestore Architektúra (összefoglaló)*: SoT = `users/{uid}/wallet` + `users/{uid}/ledger/*`
  – *Bonus Engine – Firestore Tárolási Terv (v1)*: minden pénzmozgás CF tranzakcióban, kliens wallet/ledger írás tiltott; az útvonalak egységesek legyenek
