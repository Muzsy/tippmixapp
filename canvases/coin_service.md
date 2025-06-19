## 🎯 Funkció

A `CoinService` v2 felelős a TippCoin tranzakciók teljes körű, biztonságos kezeléséért. A cél, hogy minden tranzakció:

* auditálható,
* megismételhetetlen (transactionId),
* validált (reason + amount),
* és jogosultságilag ellenőrzött legyen.

## 🧠 Fejlesztési részletek

Az új CoinService Dart oldalon működik (`/lib/services/coin_service.dart`), backend oldali logikával kiegészítve (`cloud_functions/coin_trx.ts`).

### Újítások v2-ben:

* **transactionId**: minden tranzakciónak egyedi azonosítója van, Cloud Function ellenőrzi, hogy még nem futott le korábban.
* **reason + amount korlátozás**: csak előre definiált bónusztípusok (pl. `daily_bonus`, `referral_bonus`) és azokhoz rendelt összegek engedélyezettek.
* **Admin-only műveletek** külön function-ben: coin reset, manuális beavatkozás.

### Fő metódusok:

* `creditCoin(userId, amount, reason, transactionId)`
* `debitCoin(userId, amount, reason, transactionId)`

A Cloud Function végzi el:

* a tranzakciós írást (coin\_logs)
* a user balance frissítését (Firestore `users` kollekció)
* az összes validációt (auth, típus, egyszeriség, jogosultság, maximumok)

## 🧪 Tesztállapot

* [ ] Unit tesztek: CoinService (helyes hívás, hibakezelés)
* [ ] Cloud Function tesztek: Firebase Emulatorral, invalid amount, duplikált transactionId, ismeretlen reason
* [ ] Tranzakciós rollback teszt: sikertelen írás esetén sem történik egyenlegváltozás

## 🌍 Lokalizáció

* Hibák, mint „Tranzakció elutasítva: duplikált transactionId” vagy „Ismeretlen bónusztípus” lokalizáltak
* A `reason` mező emberi olvasatra fordítható (pl. "Napi bónusz")

## 📎 Kapcsolódások

* `submitTicket()` → debitCoin hívás fogadáskor
* `AuthService.register()` → creditCoin(registration\_bonus)
* `DailyBonusJob` → creditCoin(daily\_bonus)
* `referral_bonus.ts`, `bonus_policy.md` – valid reason definíciók
* `firebase.rules` – coin\_logs create-only védelem, típus-ellenőrzés

## 📂 Dokumentációs hivatkozások

* `lib/docs/tippmix_app_teljes_adatmodell.md`
* `lib/docs/bonus_policy.md`
* `lib/docs/betting_ticket_data_model.md`
