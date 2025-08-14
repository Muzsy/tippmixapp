# Home Header – stats‑független render fix (P0)

🎯 **Funkció**
A főképernyő tetején mindig jelenjen meg a fejléc: bejelentkezett felhasználónál a profilcsempe (UserStatsHeader), vendég esetén a Guest CTA csempe. A rács (tile‑grid) a fejléc alatt minden állapotban látszódjon.

🧠 **Fejlesztési részletek**
**Valós hiba:** a `lib/screens/home_screen.dart` a teljes layoutot `userStatsProvider` `when(...)` eredményére bízta. `loading/error` esetben `SizedBox.shrink()` tér vissza → a képernyő üres marad, még bejelentkezve is. Emellett a vendég‑CTA a csempék közé kerül beszúrásra, nem a fejléc pozíciójába.

**Megoldás:**

* A `statsAsync.when(...)` blokk helyett **mindig** kirenderelünk egy `Column`‑t: felül a feltételes fejléc (auth alapján user header vagy guest CTA), alul az eddigi `GridView.count` a tile‑okkal.
* A vendég‑CTA beszúrását **eltávolítjuk** a rácsból (duplikáció megelőzése), mert a fejléc kezeli.
* A `UserStatsHeader` továbbra is megkapja a (opcionális) statokat; ha még tölt, a header „best effort” adatokkal jelenik meg (név/avatár az auth‑ból, számok 0/„—”).

🧪 **Tesztállapot**

* Kézi ellenőrzés: bejelentkezve → fejléc megjelenik; kijelentkezve → guest CTA a fejléc helyén; a rács látható mindkét esetben.
* A meglévő widget tesztek nem sérülnek (a `UserStatsHeader` továbbra is kompatibilis a nullázható stattal).

🌍 **Lokalizáció**

* Új sztring nem szükséges; a guest CTA a meglévő `home_guest_message` és login gomb sztringjeit használja.

📎 **Kapcsolódások**

* Érintett fájl: `lib/screens/home_screen.dart`
* Hivatkozott widgetek: `lib/widgets/home/user_stats_header.dart`, `lib/screens/home_guest_cta_tile.dart`
* Nincs változás a provider API‑ban: `authProvider`, `userStatsProvider` marad.
