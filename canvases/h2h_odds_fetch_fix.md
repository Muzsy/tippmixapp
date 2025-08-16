# H2H odds lekérés javítása – API‑Football (lista+tipkártya)

🎯 **Funkció**

A fogadási oldal H2H (1X2, „Match Winner”) piacának pontos és hatékony betöltése az API‑Football használatával. A cél:

* helyes API‑paraméterezés (\`bet=1\`),
* felesleges lekérések megszüntetése (ne legyen dupla/tripla hívás egy fixture‑re),
* stabil tipkártya‑megjelenítés (ne tűnjön el scroll közben),
* hibás fixture azonosító (\`0\`) ne indítson hálózati hívást.

🧠 **Fejlesztési részletek**

**Érintett fájlok (a tippmixapp.zip alapján):**

* `lib/services/api_football_service.dart`
* `lib/widgets/event_bet_card.dart`
* (tesztek) `test/services/...` és `test/widgets/...`

**Problémák (aktuális viselkedés):**

1. \`bet=1X2\` paraméter használata → API hiba („Bet field must contain an integer”).
2. Felesleges hívások: a lista betöltés közben *és* a kártya is külön‑külön kér oddsot ugyanarra a fixture‑re; sőt a kártya fallbackkel akár kétszer is kérhet.
3. A kártya azonnal hálózatra megy, mielőtt megnézné a már átadott (esetleg előtöltött) H2H‑t.
4. \`fixtureId\` parse‑hiba esetén \`0\` megy ki → érvénytelen kérés.

**Megoldás (célállapot):**

* **Helyes paraméterezés:** H2H/1X2 piachoz \`bet=1\` (a szerver oldalon „Match Winner”).
* **Lekérési stratégia:**

  * A **lista** (fixtures oldal) *csak* a meccslistát tölti (\`fixtures\`). Nem kér oddsot eleve.
  * A **kártya** H2H‑t tölt aszinkron a \`getH2HForFixture(fixtureId)\` metódussal **és** 60 mp‑es memóriacache‑sel (azonos Future visszaadása).
  * Ha a kártya már kapott H2H‑t az átadott \`event\`‑ben, **nem** indít hálózati hívást.
* **Guard:** ha \`fixtureId<=0\`, a service azonnal visszatér (nincs hálózat).
* **UI stabilitás:** a H2H megjelenítés elsődlegesen az átadott adatból történik; csak hiány esetén fut a \`FutureBuilder\`.

**Konkrét módosítások:**

* `api_football_service.dart`

  * \`\&bet=1X2\` → \`\&bet=1\` a H2H kérésnél.
  * A lista aggregáló metódusból vedd ki a per‑fixture odds hívásokat (ne töltsön H2H‑t a listában).
  * \`getH2HForFixture(...)\`: korai kilépés \`fixtureId<=0\` esetén; egyszerű 60 mp memóriacache (kulcs: \`fixture:{id}\`).
* `event_bet_card.dart`

  * Renderelés előtt ellenőrizd, van‑e H2H az átadott \`event\`‑ben; ha igen, használd azt.
  * Ha nincs, csak akkor indíts \`FutureBuilder\`‑t a \`getH2HForFixture\` hívással.

**Teljesítmény/limit hatás:**

* Listaoldal: csak 1× \`fixtures\` hívás → **gyorsabb, kevesebb API fogyasztás**.
* Kártyák: 1× H2H lekérés/fixture **cache‑elve** → nincs duplikáció.

🧪 **Tesztállapot**

*Új / frissített tesztek:*

* Service URL teszt: H2H kéréskor a query param \`bet\` értéke **"1"**.
* Fallback teszt: első hívás \`bet=1\`, üres válasz esetén második kör *bet nélkül* minden piacra, kliens oldali szűréssel.
* Kártya viselkedés: ha az \`event\` már tartalmaz H2H‑t, **nem** indul hálózati hívás; ha nem, indul és az eredményt mutatja; scroll/rebuild alatt **nem villog**.
* Guard teszt: \`fixtureId<=0\` → nincs hálózati kérés.

*Futtatás:* `flutter analyze` és `flutter test` zöld; (ha van) mock HTTP válaszok frissítve.

🌍 **Lokalizáció**

A user‑facing szövegek nem változnak lényegesen. A „Nincs elérhető piac” üzenet marad (HU/EN/DE), csak ritkábban jelenik meg, mert a H2H korrektül töltődik. Új kulcs nem szükséges.

📎 **Kapcsolódások**

* API‑Football átállás: `Api Football Migration Plan.pdf`
* Szelvénykezelés logika: `Canvases/ticket Management Detailed Logic.pdf`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`
* Következő lépés (opcionális): logó‑URL bekötés, market mapping bővítés (nem része ennek a javításnak).
