# Sprint0 – Discovery & Audit (Színséma Refaktor)

🎯 **Funkció**
A Sprint0 célja a teljes TippmixApp kódbázis hardcoded szín (hex) használatának feltérképezése, riportálása és dokumentálása. Minden színezési pont auditálva lesz, elkészül a kiindulási állapot riport, a refaktorhoz külön fejlesztői branch nyílik, amelyre minden további sprint épül.

🧠 **Fejlesztési részletek**

* Új branch: `theme_refactor_start`, CI ≥ 90% pass szükséges.
* Automatikus szín-scannelés regex alapján (pl. `0xFF[0-9A-F]{6}`), eredmény: `color_audit.csv` (hex, file, line, count oszlopokkal).
* Talált hex színek manuális kategorizálása (brand, grey, error, misc taggelés).
* Színhasználat vizualizációja (pie/bar chart, `color_usage_chart.png`).
* Jelenlegi AppColors baseline dokumentálása (`AppColors_baseline.md`).
* Canvas + Codex YAML lépéslista készül: sprint0\_color\_audit.canvas + sprint0\_steps.yaml.

🧪 **Tesztállapot**

* CI zöld (≥ 90% test pass) a branch indulásakor.
* Automatikus audit script hibátlanul lefut, CSV teljes adatot tartalmaz.
* Minden hardcoded szín felderítve, nincs rejtett hex.
* Pie/bar chart pontosan visszaadja az eloszlást.
* AppColors baseline minden aktuális színt tartalmaz.

🌍 **Lokalizáció**

* Az audit outputok (CSV, PNG, baseline.md) függetlenek a nyelvi beállítástól.
* Codex YAML lépéslista magyarul is létrehozható (nem nyelvfüggő).
* Canvas magyarázó szövegei magyarul dokumentálhatók.

📎 **Kapcsolódások**

* Következő sprint (Sprint1) minden lépése erre a baseline-ra épül.
* Az audit riport és chart bekerül a projekt dokumentációjába (/tools/reports/).
* A létrejövő refactor branch minden további fejlesztési szakasz alapja lesz.
* Codex automatizációk a yaml lépéslistából dolgoznak.

---

## Feladatbontás (Sprint0)

| ID   | Task                     | Leírás                                                        | Kimenet                                           |
| ---- | ------------------------ | ------------------------------------------------------------- | ------------------------------------------------- |
| T0.1 | Branch + CI baseline     | Új fejlesztői branch, CI ellenőrzés                           | Új branch + zöld CI badge                         |
| T0.2 | Automata szín-scannelés  | Regex audit: hardcoded hex színek kigyűjtése                  | color\_audit.csv                                  |
| T0.3 | Manuális kategorizálás   | Hex színek csoportosítása, taggelés                           | Frissített CSV                                    |
| T0.4 | Vizualizáció             | Pie/bar chart generálása az eloszlásról                       | color\_usage\_chart.png                           |
| T0.5 | AppColors baseline doksi | Aktuális AppColors gyűjtése, markdownba/screenshotba rendezve | AppColors\_baseline.md                            |
| T0.6 | Canvas + YAML készítés   | Sprint összefoglaló + codex lépéslista                        | sprint0\_color\_audit.canvas, sprint0\_steps.yaml |

---

## Definíció (Definition of Done)

* Minden színezési pont (hex) riportálva, kategorizálva, dokumentálva.
* CI pipeline zöld (≥ 90% test pass) az új branch-en.
* Canvas és yaml lépéslista elérhető a következő sprintekhez.
* AppColors baseline teljes, átlátható.
* Audit és vizualizáció minden dev számára visszakereshető.
