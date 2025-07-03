# 🎯 Funkció

A felhasználó a fogadási oldalon szelvényt tudjon feladni. Amikor legalább egy tippet hozzáad a szelvényhez, akkor jelenjen meg a szelvény feladására szolgáló lehetőség (pl. gomb vagy úszó gomb – FloatingActionButton), amely elnavigál a szelvény kitöltő (pl. CreateTicket) képernyőre.

# 🧠 Fejlesztési részletek

* A jelenlegi állapot szerint a szelvény feladása (pl. FloatingActionButton vagy egyéb gomb) nem jelenik meg, amikor van legalább egy tipp a szelvényen.
* A legvalószínűbb ok, hogy az `EventsScreen` (fogadási oldal) nem építi fel a Scaffold-on belül a gombot, vagy a navigációs logika hiányzik/nem aktív.
* A router vagy az EventsScreen kódját módosítani kell: minden esetben kerüljön Scaffold-ba, a szelvény feladására szolgáló gomb legyen látható, ha van aktív tipp.
* A gomb (FAB) megnyomásakor a `/create-ticket` vagy megfelelő route-ra kell navigálni.
* Ellenőrizni kell, hogy a régi tesztek nem várták el a gomb hiányát.

# 🧪 Tesztállapot

* Manuális teszt: tipp hozzáadása, gomb megjelenése, navigáció CreateTicket képernyőre.
* Widget tesztek: FAB/gomb csak akkor jelenik meg, ha legalább egy tipp van.
* QA: szelvény feladás tesztelése különböző sportoknál is.

# 🌍 Lokalizáció

* A gomb, hibaüzenetek, visszajelzések minden használt nyelven legyenek elérhetőek.

# 📎 Kapcsolódások

* Érintett fájlok: `lib/screens/events_screen.dart`, `lib/router.dart`, szelvény service/model, tippek kezelése
* Widget tesztek, navigációs logika
