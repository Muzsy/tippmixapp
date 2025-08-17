# Mi volt a hiba?

A `/v3/odds` hívások már kimentek, de a H2H (1X2) piac JSON‑ja sokszor **csapatneveket** ad a `values[].value` mezőben (pl. "MTK", "Győr", "Draw"), nem pedig `Home/Draw/Away` vagy `1/X/2`. A jelenlegi `MarketMapping.h2hFromApi` csak a `home/draw/away` illetve `1/x/2` értékeket ismerte fel, ezért **null**-t adott vissza → a kártyán "Nincs elérhető piac" jelent meg.

Emellett az odds hívás URL‑je eddig string fűzéssel készült (potenciális összefolyási hiba), és 429 esetet nem kezeltünk külön; a H2H cache pedig üres eredményt is 60 mp‑re eltárolt.

# Mit javítunk?

1. **Team‑név alapú felismerés** a H2H‑hez: a `h2hFromApi` mostantól opcionálisan megkapja a `homeName`/`awayName` paramétereket és ezek alapján ismeri fel a kimeneteket. Normalizált összehasonlítást használ (kisbetűsítés, ékezet/pont jellegű karakterek kidobása, " FC" eltávolítás).
2. **Alias bővítés**: hozzáadva a `"home/away"` is, így ha csak két kimenetet ad a bookmaker, akkor is visszaadunk H2H piaci kimeneteket (Draw nélkül, a UI ekkor „—”‑t tesz a döntetlenre).
3. **A hívó továbbítja a neveket**: az `EventBetCard` átadja az `event.homeTeam`/`event.awayTeam` értékeket a service‑nek.
4. **URL összeállítás `Uri`‑val**: nem tud összefolyni a `season` és a `bet` query.
5. **429 kezelés**: 200 ms backoff + 1× retry a `/v3/odds` hívásnál.
6. **No‑cache‑on‑null**: üres/hibás H2H eredményt **nem** cache‑elünk 60 mp‑re, csak sikereset.

# Hatás / Elfogadási feltételek

* A tippkártyákon megjelennek az 1 / X / 2 oddsok (ha az API szolgáltatja a piacot).
* A terminalban látszik a helyes URL (`[odds] GET …/v3/odds?fixture=…&season=…&bet=1`).
* A dashboard „Requests” nézetben `/v3/odds` sorok megjelennek.
