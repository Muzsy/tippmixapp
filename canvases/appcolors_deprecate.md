# AppColors deprecálása és archiválása

---

🎯 **Funkció**

A Sprint 1 végső lépéseként az AppColors központi színtároló teljes mértékben kivezetésre kerül. Ezzel lezárul a hard-coded színek használata a projektben, minden szín csak theme-ből vagy ThemeExtension-ből érhető el. Az AppColors csak visszamenőleges kompatibilitás miatt kerül archiválásra.

---

🧠 **Fejlesztési részletek**

- A `lib/AppColors.dart` fájlt helyezd át a `/legacy` könyvtárba (`legacy/AppColors.dart`).
- Lásd el a teljes fájlt és minden osztályát/funkcióját @Deprecated kommenttel.
- Törölj minden AppColors importot és hivatkozást a codebase-ből (különösen a lib/ és minden UI/widget fájlban).
- Frissítsd a dokumentációt (README, Theme Management), hogy AppColors már csak archivált állapotban van jelen.
- Minden új színkezelés kizárólag a ThemeBuilder vagy ThemeExtension (pl. BrandColors) felől történhet.

---

🧪 **Tesztállapot**

- Futtass lintert és statikus kódanalízist, hogy nincs több AppColors-referenciát tartalmazó aktív kódrész.
- A projekt minden tesztje továbbra is 100% zöld, nincs regresszió.
- Az archivált AppColors a /legacy mappában elérhető, de nem használható a fő codebase-ben.

---

🌍 **Lokalizáció**

- A színkezelés nem tartalmaz lokalizációs mezőket.
- Dokumentációban (ha szükséges) egyértelműen szerepel, hogy az AppColors már nem aktív.

---

📎 **Kapcsolódások**

- **ThemeBuilder és ThemeExtension**: minden UI elem csak ezeken keresztül kaphat színt.
- **Linter/CI**: tiltja a hardcoded színt, és az AppColors-használatot.
- **/legacy**: archivált, de nem aktív állományok helye.

---
