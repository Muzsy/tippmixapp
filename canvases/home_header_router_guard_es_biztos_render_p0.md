# Home Header – Router guard + biztos render (P0)

🎯 **Funkció**
A főképernyő tetején **mindig** jelenjen meg a fejléc: bejelentkezve a profilcsempe (UserStatsHeader), vendégnél a Guest CTA. A rács (tile‑grid) a fejléc alatt minden állapotban látszódjon. Vendégként **NE** dobjon át a login oldalra a „/” útvonalon.

🧠 **Valós hiba (kettős)**

1. **Router guard** a `lib/router.dart`‑ban: nem autentikált állapotban **minden** útvonalat (köztük a „/” otthont is) a `/login`‑re terel → ezért vendégként a Home helyett a login jelenik meg.
2. **Home render** a `lib/screens/home_screen.dart`‑ban: a teljes layout `userStatsProvider.when(...)` köré volt szervezve → `loading/error` esetén üres `SizedBox`, így bejelentkezve is kiürülhet a képernyő.

🔧 **Megoldás**

* Router: engedélyezett publikus útvonalak listája (`/`, `/login`, `/register`, `/onboarding`). Csak akkor irányítson a guard `/login`‑re, ha **nem autentikált** ÉS **nem** publikus útra próbál lépni.
* Home: a `when(...)` blokk helyett stabil `Column`/Sliver layout, fejléc auth‑alapon: bejelentkezve `UserStatsHeader`, vendégnél `HomeGuestCtaTile`. A rács **mindig** renderel.

🧪 **Tesztállapot**

* Vendég: „/” → fejlécben Guest CTA + alul rács. Nem ugrik `/login`‑re.
* Bejelentkezve: „/” → profilfejléc (név/coin/win‑ratio) + rács. Nincs üres fehér képernyő `loading` közben sem.

🌍 **Lokalizáció**

* Új kulcs **nem** szükséges.

📎 **Kapcsolódások**

* Fájlok: `lib/router.dart`, `lib/screens/home_screen.dart`
* Hivatkozott widgetek: `UserStatsHeader`, `HomeGuestCtaTile`
