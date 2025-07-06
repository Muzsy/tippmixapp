# Sprint 1 – Core Theme Architecture összefoglaló (Canvas)

---

🎯 **Funkció**

A Sprint 1 célja egy új, modern, bővíthető és auditálható színséma-architektúra kiépítése a TippmixApp-ban. A canvas összegzi a FlexColorScheme-re, ThemeBuilder-re, ThemeService-re, BrandColors ThemeExtension-re és a teljes színséma logikára épülő fejlesztési lépéseket. Minden lépés és eredmény standardizált, a projekt minden következő sprintjéhez sablonként szolgál.

---

🧠 **Fejlesztési részletek**

- Az összes Sprint 1-hez tartozó feladat, architektúra, döntés, technikai megvalósítás és minta, beleértve:
    - ThemeBuilder és ThemeService kódváz, használati logika
    - BrandColors ThemeExtension szétválasztott implementációja (definíció + presetek)
    - main.dart migráció, AppColors archiválása
    - Unit-tesztek és tesztelési stratégiák
    - Linter, CI, coverage követelmények
- A canvas minden lépése egyértelműen hivatkozik a kapcsolódó yaml lépésekre, kódra, tesztre, dokumentációra.
- Ez a canvas minta lesz a további fejlesztési és Codex automatizált workflow-k alapja.

---

🧪 **Tesztállapot**

- Minden dokumentált lépéshez tartozik unit-teszt, elfogadási kritérium, CI-ban zöld futás.
- A canvas alapján minden fejlesztő egyértelműen követheti a teljes theme-architektúra integrációt.

---

🌍 **Lokalizáció**

- A canvas és a hozzátartozó yaml magyar nyelvű, projektstandard szerint íródott.
- A theme logika nem tartalmaz lokalizációt, de skin leírás, név később bővíthető.

---

📎 **Kapcsolódások**

- **/codex/goals/canvases/fill_canvas_sprint1_core_theme.yaml**: minden feladathoz yaml automatizáció.
- **docs/Theme Management.md**: a teljes architektúra leírása.
- **Unit-teszt fájlok, legacy/AppColors archivált állapot**.
- Minden további sprint a canvas szerkezetét követi.

---
