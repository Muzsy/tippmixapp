# Fogadási oldal – H2H és szűrők javítása

## Összefoglaló
- Helyes Match Winner paraméter: `&bet=1`.
- A fixtures lista csak a meccseket tölti, a kártyák kérik le a H2H-t 60 mp-es memóriacache-sel.
- A `getH2HForFixture` védi az érvénytelen azonosítókat és cache-el.
- A service és a cache figyelembe veszi a választott dátumot (`fixtures?date=YYYY-MM-DD`), cache kulcs: `sport|date|country|league`.
- Az Ország/Liga dropdown első eleme a "Bármelyik" opció (null érték).
- A H2H kérések 10 mp-es timeouttal és egy retry-jal futnak.
- Új egység- és widget tesztek: URL építés, fallback logika, dátumszűrés.
