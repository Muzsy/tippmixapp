# 🎯 Funkció

A `CoinService` a felhasználói TippCoin műveleteket végzi el a kliens oldalon. Fő célja, hogy HTTP callable felhívásán keresztül kezdeményezzen egyenleglevonást vagy jóváírást a Firebase Functions segítségével.

# 🧠 Fejlesztési részletek

* A `debitCoin` és `creditCoin` metódusok egy Firebase callable function-t hívnak meg (`coin_trx`).
* A függvényhívás paraméterei: `amount`, `reason`, `transactionId`. A `userId` nem szükséges, azt a szerver `context.auth.uid` alapján határozza meg.
* A válaszban `{ success: true }` objektumot várunk, hibák esetén `FirebaseFunctionsException`-t dobunk tovább.

# 🧪 Tesztállapot

* Nincs hozzá dedikált unit test, a hibakezelés `try/catch` alapon működik.
* A sikeres válasz esetén nincs további visszaellenőrzés, csak a hiba esetén történik naplózás vagy feldobás.

# 🌍 Lokalizáció

Nem érint lokalizációs funkciókat.

# 📎 Kapcsolódások

* `lib/services/bet_slip_service.dart` → meghívja a `CoinService.debitCoin` metódust
* `functions/src/coin_trx.logic.ts` → a szerveroldali callable végpont, amely ténylegesen kezeli az egyenlegmódosítást
* `firebase_auth` → az aktuális felhasználói azonosítót (`uid`) a szerver oldalon szerzi be
