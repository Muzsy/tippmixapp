# Wallet path hotfix – minden modulban (CF + Rules + kliens)

## Mi történt?

A mostani `tippmixapp.zip` alapján az **onUserCreate** továbbra is a hibás Firestore dokumentum‑utat használja: `db.doc(`users/\${uid}/wallet`)`. Ez **páratlan szegmensű** útvonal (collection/doc/collection), ezért *document* referenciának érvénytelen → a trigger hibára áll, és **nem** jön létre a wallet.

Ugyanez a minta több helyen is jelen van (CoinService, bonus\_claim, admin\_coin\_ops, kliens `stats_service.dart`). Emiatt a wallet/ledger SoT nem tud létrejönni.

## Mit javítunk most?

A walletet egységesen **alkollekció + fix azonosítójú dokumentum** formára visszük:

```
users/{uid}/wallet/main  (doc)
users/{uid}/ledger/{entryId} (doc)
```

Ez minden SDK‑ban egyértelmű és érvényes útvonal (collection/doc/collection/doc), nincs több odd‑segments hiba.

## Érintett fájlok

* `cloud_functions/coin_trx.logic.ts` – onUserCreate + coin\_trx tranzakción belüli wallet hivatkozás
* `cloud_functions/src/services/CoinService.ts` – walletRef
* `cloud_functions/src/bonus_claim.ts` – daily bonus tranzakció walletRef
* `cloud_functions/admin_coin_ops.ts` – admin reset/read wallet
* `lib/services/stats_service.dart` – kliens oldali olvasás
* Rules: `firebase.rules` és `cloud_functions/firestore.rules` – `match /users/{uid}/wallet/{docId}`

## Acceptance

* Új regisztráció után létrejön: `users/{uid}/wallet/main { coins: 50 }`.
* Ha `system_configs/bonus_rules.signup.enabled = true`, létrejön a `users/{uid}/ledger/bonus:signup` és a wallet növekszik a bónusszal.
* `grep -R "\`users/\${...}/wallet\`" cloud\_functions`→ **nincs találat** (mindenhol`wallet/main\`).
* Kliens: a `stats_service.dart` már `users/$uid/wallet/main`‑ról olvas.

## Hivatkozás

YAML: `/codex/goals/canvases/fill_canvas_wallet_path_fix_and_rules_update.yaml`
