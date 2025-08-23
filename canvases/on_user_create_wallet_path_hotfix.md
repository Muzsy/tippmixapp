# Bugfix – onUserCreate wallet path javítás

## 🎯 Funkció

Regisztrációkor az `onUserCreate` Cloud Function feladata, hogy létrehozza a user alapdokumentumát, valamint egy `wallet` doksit 50 kezdő coin értékkel, és opcionálisan jóváírja a signup bónuszt. Jelenleg hibára fut a wallet létrehozásánál.

## 🧠 Probléma

A kódban `db.doc("users/${uid}/wallet")` hívás szerepel, ami **páratlan számú path komponens**, így a Firestore kliens hibát dob: *„Value for argument "documentPath" must point to a document”*【525†source】. Emiatt a wallet doksi nem jön létre, és a további logika (signup bonus) sem fut le.

## 🔧 Megoldás

A `wallet` a terv szerint **egyetlen dokumentum** a `users/{uid}` alatt【526†source】【527†source】:

```
users/{uid}/wallet (doc)
  coins: number
  updatedAt: Timestamp
```

A kódban a helyes referencia:

```ts
const walletRef = db.collection('users').doc(uid).collection('wallet').doc('main');
```

Ha egyetlen doksi kell, akkor `doc('main')` vagy más fix ID szükséges, mert a Firestore nem enged „kollekció szintű set()”-et.

## 📎 Érintett fájl

* `cloud_functions/src/coin_trx.logic.ts`

## 🧪 Teszt

1. Deploy után regisztrálj új usert.
2. Firestore-ban azonnal létrejön:

   * `users/{uid}` doksi (createdAt),
   * `users/{uid}/wallet/main` doksi `coins: 50`,
   * ha van `system_configs/bonus_rules.signup.enabled=true`, akkor `users/{uid}/ledger/bonus:signup` is.
3. Logban nincs több „Value for argument documentPath” hiba.

## 🌍 Lokalizáció

Nem érint fordítást.

## 📌 Hivatkozás

Codex futtatás: `/codex/goals/canvases/fill_canvas_onusercreate_wallet_fix.yaml`
