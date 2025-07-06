🎯 Funkció
A Sprint2 célja minden hard-coded színhasználat teljes kiváltása Theme/ThemeExtension-re, a projektben maradó színek központi szabályozása, a vizuális konzisztencia és a hozzáférhetőség garantálása. A sprint végén a teljes kód hex/Colors.*/manuális színtől mentes, a vizuális regressziók kizártak, a minőségi kapuk (linter, golden, a11y audit) aktívak.

🧠 Fejlesztési részletek
Feladatbontás:

T2.1: Codemod script elkészítése hex és Colors.* cserére (elméleti lépés, audit alapján).

T2.2: Manuális review (color_audit.csv alapján), minden színhasználat mappingja Theme-re vagy ThemeExtension-re.

T2.3: Automatikus refaktor (codemod vagy manuális csere) az egyszerű esetekre.

T2.4: Manuális refaktor bonyolult, speciális helyeken (brand színek, shimmer, chart, gradient, opacity).

T2.5: Linter szabály bevezetése (avoid-hard-coded-colors), CI blokkol minden manuális színt.

T2.6: Golden tesztek újrafelvétele, minden képernyő/skin/brightness kombinációban.

T2.7: Hozzáférhetőségi audit accessibility_tools-szal, minden warning javítva.

T2.8: Canvas + yaml, dokumentáció, visszakereshetőség.

Állapot:

Minden widget kizárólag Theme/ThemeExtension alapján színez.

Brand színek központilag, ThemeExtension-ben, linter ignore-dal, auditáltan.

Golden baseline frissítve, vizuális regresszió nincs.

Accessibility audit warningmentes, CI-ben is fut.

Linter warning = 0, manuális szín nincs.

Artefaktok:

color_audit_reviewed.csv, manual_color_refactors.txt

/test/goldens/ PNG baseline

a11y_report.html

analysis_options.yaml frissítés

brand_colors_preset.dart linter ignore

összefoglaló canvas + yaml

Eljárás:

Kézi beavatkozás (pubspec.yaml, golden png commit) Codex workflow-ban NEM automatizálható, ezekre megjegyzés.

Minden dev, QA, design lépés visszakereshető és dokumentált.

🧪 Tesztállapot
CI minden lépésen zöld (linter, golden, a11y).

Manuális audit, szemrevételezés, accessibility validáció is hibamentes.

🌍 Lokalizáció
A theme/brand nevek és leírások lokalizálhatók.

Az accessibility auditban minden alternatív szöveg helyesen jelenik meg.

📎 Kapcsolódások
Előzmény: Sprint0 (audit), Sprint1 (ThemeBuilder, ThemeService).

Sprint3-ban már csak skin-váltás, dark mode, dinamikus skinek, storage lesz a fókuszban.

A dokumentációt a /canvases és /codex/goals mappában, a yaml-t a Codex workflow szabályai szerint kell tárolni.