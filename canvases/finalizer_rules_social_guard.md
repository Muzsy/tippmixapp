# Bugfix csomag – match\_finalizer Secret-scope, Pub/Sub wrapper egyszerűsítés, Firestore rules (friendRequests), SocialService auth‑guard

## Kontextus

A `match_finalizer` Gen2 Pub/Sub függvény időnként a `Cannot read properties of undefined (reading 'messageId')` hibával állt le a `firebase-functions` wrapperben. A kódban a `API_FOOTBALL_KEY.value()` modul-szinten került kiolvasásra és a provider példányosítása is modul-szinten történt. A Firestore szabályokban hiányzott a `relations/{uid}/friendRequests/{requestId}` ág, miközben a klienskód erre az útra ír. A Flutter `SocialService` `currentUser!` non-null assertiont használ, ami auth nélküli állapotban futásidejű hibához vezethet. Az `admin_coin_ops` callable nincs exportálva az `index.ts`‑ből.

## 🎯 Funkció

* A Secret felhasználását a `match_finalizer` **handler scope**‑jába mozgatjuk, hogy a Secret értéke a futás idejében legyen kiolvasva.
* A Pub/Sub trigger regisztrációját **egyszerű, topic‑string** szignatúrára váltjuk (`onMessagePublished('result-check', ...)`), a globális `setGlobalOptions` már gondoskodik a régióról és a secretről.
* Firestore rules kiegészítése a `friendRequests` útvonalra.
* `SocialService` auth‑guard: biztonságos `_uid` getter, ne dőljön el `currentUser!` miatt.
* `admin_coin_ops` export hozzáadása az `index.ts`‑hez.

## 🧠 Fejlesztési részletek

* `cloud_functions/src/match_finalizer.ts`: a modul-szintű `provider` példány helyett a handleren belül példányosítjuk az `ApiFootballResultProvider`‑t, a `API_FOOTBALL_KEY.value()` olvasással együtt.
* `cloud_functions/index.ts`: a `onMessagePublished` hívást opciós objektumról egyszerű string paraméteres formára állítjuk. A globális opciók (`global.ts`) továbbra is beállítják a `region`‑t és a `secrets`‑et.
* `cloud_functions/firestore.rules`: új `match /relations/{uid}/friendRequests/{requestId}` blokk – a kliens által használt útvonal engedélyezése kontrolláltan.
* `lib/services/social_service.dart`: `_auth.currentUser!` helyett guardolt getter, amely egyértelmű hibát dob nem bejelentkezett állapotban.
* `cloud_functions/index.ts`: `export { admin_coin_ops } from './admin_coin_ops';`

## 🧪 Tesztállapot

* Cloud Functions: `npm -C cloud_functions run lint && npm -C cloud_functions test` zöld.
* Flutter: `flutter analyze` hibamentes. A változtatás nem befolyásolja a publikus API‑t.

## 🌍 Lokalizáció

* Nincs új felhasználói felület szöveg; i18n módosítás nem szükséges.

## 📎 Kapcsolódások

* Kapcsolódó logok: `mf_diag_tippmix-dev_europe-central2_match_finalizer_20250828_203830.log` (messageId wrapper hiba)
* Globális beállítások: `cloud_functions/global.ts` (region + secrets)
* Kliens hívások: `lib/services/social_service.dart`
* Lásd a hozzá tartozó YAML-t: `/codex/goals/fill_canvas_finalizer_rules_social_guard.yaml`
