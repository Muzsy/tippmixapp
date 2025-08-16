# H2H piacok – API‑Football odds parser javítás

**Cél:** a tippkártyákon minden eseménynél jelenjen meg az 1‑X‑2 (H2H) gombsor.

## Röviden

A „Nincs elérhető piac” üzenet azért jelent meg, mert a `MarketMapping.h2hFromApi()` a régi (OddsAPI-s) JSON‑sémát várta (`markets` kulcs), miközben az API‑Football a `response[0].bookmakers[].bets[].values[]` struktúrában adja vissza a H2H piacot (tipikusan a **Match Winner / 1X2** bet alatt). Emiatt a H2H parser minden esetben `null`‑t adott vissza, és a kártya nem tudott gombokat építeni.

## Megoldás

* **Parser csere** a `MarketMapping.h2hFromApi()` függvényben: közvetlenül a `response → bookmakers → bets → (Match Winner|1X2) → values` útvonalról állítjuk össze a `H2HMarket`‑et.
* **Aliasok bővítése:** ("Match Winner", "1X2", "Full Time Result", stb.)
* **Számformátum robusztus kezelése:** vessző/pont csere, majd `double` parse.
* **Rendezett kimenet:** Home‑Draw‑Away sorrend biztosítása.
* **Kiegészítő unit teszt**: minimál odds‑mintán ellenőrzi, hogy 3 kimenet keletkezik.

## Várható hatás

* A `FutureBuilder` a `getH2HForFixture()` híváson keresztül már **nem null** piacot kap, így minden kártyán megjelenik a H2H gombsor.
* A meglévő `_parseH2HBookmakers` továbbra is működik (az eseménylistához használt minimalista konverzió), a két út konzisztens.

## Kockázat/rollback

* A módosítás visszafelé kompatibilis: csak a H2H parsert érinti. Ha gond lenne, a kártya visszaesik a "Nincs elérhető piac" állapotra; funkcionalitást nem törünk.

---

**Következő lépés:** a hozzá tartozó Codex YAML a konkrét patchekkel és tesztekkel (futtatható).
