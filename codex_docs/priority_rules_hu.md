version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[priority\_rules\_en.md]

# 🚦 Prioritási és Súlyossági Szabályok

> **Cél**
> Egységes skálát biztosítani, hogy a Codex és az emberi fejlesztők ugyanúgy rangsorolják a hibákat, biztosítva, hogy az üzletileg kritikus problémák kerüljenek először javításra.

---

## Prioritási mátrix

| Szint  | Címke                       | Kritériumok                                                                                                                           | Várható javítási SLA                       |
| ------ | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| **P0** | **Kritikus / App‑blokkoló** | • Az alkalmazás összeomlik indításkor  <br>• Adatvesztés vagy sérülés  <br>• Biztonsági rés aktív kihasználással                      | **Azonnal** (≤ 2 óra)                      |
| **P1** | **Magas**                   | • Fő funkció használhatatlan (pl. nem lehet fogadást kötni)  <br>• Nincs életképes kerülő megoldás  <br>• Teljesítménycsökkenés >50 % | **24 órán belül**                          |
| **P2** | **Közepes**                 | • Funkció részben hibás, de van kerülő megoldás  <br>• Kisebb teljesítményprobléma  <br>• Hibás fordítás                              | **Következő sprint**                       |
| **P3** | **Alacsony**                | • Kozmetikai UI‑hiba  <br>• Szövegmódosítás  <br>• Nem blokkoló javaslat                                                              | **Háttérfeladat** (kapacitás függvényében) |

> **Megjegyzés**: Az időkeretek a Europe/Budapest időzóna szerinti munkanapokra vonatkoznak.

---

## Folyamatszabályok

1. **Jelentő felelőssége** – A hibajegyet a fenti mátrix alapján kezdeti `P?` prioritással kell ellátni.
2. **Triage meeting** – A Product Owner és a Tech Lead 24 órán belül megerősíti vagy módosítja a prioritást.
3. **Eskalációs útvonal** – Bármely csapattag egy szinttel feljebb eskalálhat indoklással; a végső döntés a Tech Lead-é.
4. **SLA‑követés** – A CI pipeline automatikusan címkézi a `P0/P1` hibákat javító PR‑eket; az SLA megszegése Slacken piros státuszt generál.

---

## Példák

| Szenárió                                                               | Összerendelt prioritás | Indoklás                                       |
| ---------------------------------------------------------------------- | ---------------------- | ---------------------------------------------- |
| A bejelentkezési képernyő fehér iOS‑en, az alkalmazás használhatatlan  | **P0**                 | Blokkoló, nincs kerülőút                       |
| Az odds frissítés 3–4 s‑re befagy, de a fogadás továbbra is lehetséges | **P1**                 | Fő funkció érintett, rossz felhasználói élmény |
| A „Stake” holland fordítása hibás                                      | **P2**                 | Kisebb tartalmi hiba                           |
| A Beállítások ikon paddingje elcsúszott                                | **P3**                 | Csak kozmetikai                                |

---

## Változásnapló

| Dátum      | Szerző   | Megjegyzés                 |
| ---------- | -------- | -------------------------- |
| 2025-07-29 | docs-bot | Első dokumentum létrehozva |
