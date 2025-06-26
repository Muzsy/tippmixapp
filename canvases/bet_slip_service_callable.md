# 🎯 Funkció

A `BetSlipService` osztály a szelvények beküldéséért felelős. A `submitTicket` metódus végzi el a tipp szelvény összeállítását, a tét összegének levonását TippCoinból, és a szelvény mentését a Firestore adatbázisba.

# 🧠 Fejlesztési részletek

* A metódus kiszámolja az összoddszorzót és a várható nyereményt.
* A szelvény azonosító egy UUID, amit minden hívásnál generál.
* A szelvényt a bejelentkezett felhasználó nevében hozzuk létre (`FirebaseAuth.instance.currentUser`).
* Az egyenleglevonást a `CoinService.debitCoin` metódusa végzi egy HTTPS callable function hívással.
* Csak akkor mentjük el a szelvényt Firestore-ba, ha a TippCoin levonás sikeres volt.

# 🧪 Tesztállapot

* Hibakezelés `try/catch`-ben történik a callable hívás körül.
* A sikeres levonás után történik a `tickets/{ticketId}` dokumentum mentése.
* A userId nem paraméter, hanem az aktuálisan bejelentkezett Firebase userből származik.

# 🌍 Lokalizáció

Nem tartalmaz lokalizációs logikát.

# 📎 Kapcsolódások

* `lib/services/coin_service.dart` – a CoinService végzi a HTTP callable meghívását.
* `functions/src/coin_trx.logic.ts` – a callable function, ami a szerveren levonja a TippCoint.
* Firestore `tickets` kollekció – ide mentjük el a szelvényt a sikeres tranzakció után.
