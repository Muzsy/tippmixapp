# Legacy kivezetés + kliens 100% átállítás (users/{uid}/wallet + ledger + tickets)

## Kontextus

A refaktor lezárult: a pénzügyi SoT a `users/{uid}/wallet` + `users/{uid}/ledger/*`, a szelvények a `users/{uid}/tickets/*` alatt élnek. A teljes átállításhoz el kell távolítani a **legacy kollekciókra** ( `coin_logs`, `wallets/*`, illetve a `users/{uid}.coins` fallback) vonatkozó maradványokat a **Rules** és a **kliens** kódból.

## 🎯 Cél

1. **Rules**: a `coin_logs` és a `wallets/*` blokkok **eltávolítása** mind a gyökér `firebase.rules` , mind a `cloud_functions/firestore.rules` fájlból.
2. **Kliens**: a `users/{uid}.coins` fallback **kivágása**; kizárólag a `users/{uid}/wallet.coins` alapján számolunk. A „coin\_logs”‑hoz kötődő **deprecated** modell/szerviz törlése.
3. **Őrszálak**: grep‑ellenőrzések, hogy ne maradjon használat `wallets/` vagy `collection('coin_logs')` alatt.

## Változási felület (összefoglaló)

* Rules:

  * `firebase.rules`: töröljük a `match /coin_logs/{logId}` és `match /wallets/{userId}` blokkokat.
  * `cloud_functions/firestore.rules`: ugyanígy törlés.
* Flutter kliens:

  * `lib/services/stats_service.dart`: megszűnik a `userDoc.data()['coins']` fallback – csak `wallet` doksiból olvasunk.
  * `lib/models/tippcoin_log_model.dart` és `lib/services/tippcoin_log_service.dart` **törlése** (deprecated; nem referenciált a futó kódban).

## Acceptance / Done

* [ ] `flutter analyze` zöld.
* [ ] `grep -R "wallets/"` a forrásban **nincs találat** (kivéve README/archív doksi).
* [ ] `grep -R "collection('coin_logs')" lib/` **nincs találat**.
* [ ] Mindkét Rules fájlban **nincs** `coin_logs` és `wallets/*` blokk.

## Hivatkozás

* YAML: `/codex/goals/canvases/fill_canvas_legacy_cleanup_client_migration.yaml`
