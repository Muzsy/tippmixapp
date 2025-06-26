# 🎯 Funkció

A `functions/src/index.ts` fájl a Firebase Functions belépési pontja, ahol az összes exportált szerveroldali funkció regisztrálásra kerül.

# 🧠 Fejlesztési részletek

* Az összes callable és trigger függvényt innen exportáljuk, hogy a `firebase deploy` parancs automatikusan érzékelje.
* A korábbi `coin_trx` Firestore-onCreate trigger kivezetésre került, helyette egy HTTPS callable funkció (`coin_trx`) van használatban.
* Emellett bekerült egy új `onUserCreate` trigger is, ami a Firebase Authentication új felhasználóinak létrejöttekor automatikusan inicializálja a Firestore `users/{uid}` dokumentumát 0 TippCoinnal.

# 🧪 Tesztállapot

* A deploy működése a `firebase deploy --only functions` parancson keresztül ellenőrizhető.
* A `coin_trx` callable funkció a `functions/coin_trx.logic.ts` fájlból van importálva.
* Az `onUserCreate` trigger ugyanabból a fájlból származik.

# 🌍 Lokalizáció

Nem érint lokalizációt.

# 📎 Kapcsolódások

* `functions/coin_trx.logic.ts` – tartalmazza a `coin_trx` callable és az `onUserCreate` auth trigger implementációját
* `lib/services/coin_service.dart` – meghívja a callable függvényt
* Firebase Authentication – az `onUserCreate` trigger aktiválódásához
