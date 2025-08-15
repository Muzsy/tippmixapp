# Home Header – Splash & Root Route fix (P0)

🎯 **Funkció**
A főképernyő tetején **mindig** jelenjen meg a profilfejléc (bejelentkezve: `UserStatsHeader`, vendégként: `HomeGuestCtaTile`), a csempés rács pedig **minden állapotban** látszódjon. Vendég esetén a „/” útvonal **ne** terelődjön át a login oldalra.

🧠 **Fejlesztési részletek**
**Valós hibák:**

1. `lib/controllers/splash_controller.dart` – ha a `FirebaseAuth.instance.currentUser` `null`, a Splash **mindig** `AppRoute.login`-re küldi a felhasználót. Emiatt vendégként sosem jutunk a „/” (Home) útvonalra, így a Guest‑CTA fejléc nem látszhat.
2. `lib/router.dart` – a „/” útvonal `AuthGate`-et ad a ShellRoute „child”-jaként. Bár a HomeScreen figyelmen kívül hagyja az `AuthGate`‑et a fejléc/jelenet renderelésekor, biztonságosabb, ha a „/” gyerek komponense **üres** widget (nem login), így biztosan nem írja felül az elrendezést.

**Megoldás:**

* Splash: vendég esetén **Home**‑ra navigálunk (`AppRoute.home`), így a ShellRoute `HomeScreen` + fejléc/rács tud renderelni.
* Router: a „/” route gyereke `SizedBox.shrink()` lesz `AuthGate` helyett. A login külön útvonalként érhető el (`/login`).

🧪 **Tesztállapot**

* Vendég: `/splash` → `/` → a fejlécben **Guest CTA**, alatta csempék.
* Bejelentkezett: `/splash` → `/` → a fejlécben **UserStatsHeader**, alatta csempék. Nincs üres fehér képernyő.

🌍 **Lokalizáció**

* Nem igényel új fordítási kulcsot.

📎 **Kapcsolódások**

* Fájlok: `lib/controllers/splash_controller.dart`, `lib/router.dart`
* Érintett komponensek: `HomeScreen`, `UserStatsHeader`, `HomeGuestCtaTile`
