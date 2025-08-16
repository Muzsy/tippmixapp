# H2H odds – season + UI fallback javítás (API‑Football)

🎯 **Funkció**
A focis eseménykártyákon (fogadási oldal) a H2H (1X2) oddsok megbízható megjelenítése. A cél, hogy scroll és rebuild közben se tűnjenek el a gombok, illetve akkor is legyen megjelenítés, ha az API elsődleges (bet=1X2) lekérése üres választ ad.

🧠 **Fejlesztési részletek**

* **Kiinduló állapot**: A beszélgetések és a `vizsgalat.txt` szerint a H2H néha felvillan, majd eltűnik. Oka: a UI a `FutureBuilder` eredményére támaszkodik; ha a season nélküli lekérés üresen jön, „Nincs elérhető piac” fallback jelenik meg.
* **A jelenlegi kódbázis (tippmixapp.zip) ellenőrzése**:

  * `lib/services/api_football_service.dart` már tartalmaz **season paramétert** és **kétlépcsős lekérést** (először `bet=1X2`, majd teljes piaclista), valamint **fixture+season alapú cache‑kulcsot**.
  * `lib/widgets/event_bet_card.dart` átadja a `season` értéket, **de ha null**, nem állít be évet, és **nincs UI‑szintű fallback** az eseményben már előkészített H2H adatokra.
* **Javítás tartalma (csak UI)**:

  1. A Future hívásnál `season: event.season ?? DateTime.now().year` – így hiányzó season esetén is a megfelelő év kerül átadásra.
  2. **UI‑fallback**: ha a `snapshot.data == null`, akkor az `event.bookmakers` → `markets` közül a `key == 'h2h'` alapján építjük fel a H2H gombokat (`H2HMarket(outcomes: ...)`).
* **Érintett fájl**: `lib/widgets/event_bet_card.dart`.
* **Kockázat**: minimális; a módosítás csak megjelenítésre hat, a service és a cache működése változatlan.

🧪 **Tesztállapot**

* **Unit**: A market‑mappinghez már vannak tesztek a repo‑ban. A mostani változtatás UI‑szintű fallback, ezért a meglévő tesztek nem sérülnek.
* **Kézi ellenőrzés**:

  * Lista megnyitása → H2H gombok következetesen látszanak.
  * Scroll/rebuild után is megmaradnak.
  * Gyenge hálózat/üres első hívás esetén a fallback kirajzolja a gombokat, ha az eseményben elérhető volt H2H.

🌍 **Lokalizáció**

* Nincs új felirat; meglevő i18n kulcsok használata (`events_screen_no_market`).

📎 **Kapcsolódások**

* Források: `vizsgalat.txt`, `Api Football Migration Plan.pdf`, `Canvases_api Football Migration Status Report.pdf`.
* Kódmodulok: `api_football_service.dart`, `market_mapping.dart`, `event_bet_card.dart`.
* Állapotkezelés: `oddsApiProvider`, `betSlipProvider`.
