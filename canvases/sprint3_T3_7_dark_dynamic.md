T3.7 – Golden & accessibility (a11y) tesztek frissítése
🎯 Funkció
A cél, hogy a TippmixApp minden skin × light/dark kombinációjára friss golden tesztek (screenshot baseline) és hozzáférhetőségi audit (WCAG AA) készüljön. Ez biztosítja, hogy minden vizuális és accessibility elvárásnak megfeleljen az új színséma- és skin-váltó rendszer.

🧠 Fejlesztési részletek (módosítva)
Golden teszt:

Minden képernyőhöz, minden skin × light/dark mód kombinációban készíts manuálisan screenshot baseline-t (/test/goldens/).

A generálás, frissítés és commit kizárólag fejlesztői (nem Codex) feladat, Codex csak dokumentálja a lépést.

Accessibility audit:

Használd az accessibility_tools csomagot a teljes alkalmazás auditálásához.

Audit riportot generálj (pl. a11y_report.html), commit szintén csak manuálisan történhet.

CI pipeline integráció:

Csak akkor PR, ha minden golden és accessibility teszt manuálisan zöld.

Linter: avoid-hard-coded-colors szabály aktív.

Tesztelés:

Minden skin- és módváltás manuálisan ellenőrizve, coverage dokumentálva.

🧪 Tesztállapot
Friss golden baseline minden kombinációra.

Accessibility audit eredménye hibamentes.

CI pipeline minden lépésen zöld.

🌍 Lokalizáció
A jelentés, audit, és teszteredmények magyarul és angolul is elérhetők (opcionális).

UI feliratok, szövegek minden skin/mód alatt megfelelően jelennek meg.

📎 Kapcsolódások
T3.1–T3.6: Minden vizuális és accessibility logika.

test/goldens/: Screenshot baseline tárolása.

tools/reports/a11y_report.html: Accessibility audit log.

CI pipeline: Minőségi kapu (golden/a11y).

Linter: avoid-hard-coded-colors szabály fenntartása.