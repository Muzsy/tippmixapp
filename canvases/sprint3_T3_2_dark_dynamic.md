🎯 Funkció
A cél, hogy a TippmixApp-ban a felhasználó egy gombnyomással válthasson világos és sötét mód között. A sötét mód kapcsolója a Beállítások menüben jelenik meg, és minden skin-hez elérhető. A váltás azonnal, minden képernyőn érvényesül, a választás a ThemeService-ben perzisztensen tárolódik (lásd T3.1).

🧠 Fejlesztési részletek
A ThemeService-ben elérhetővé kell tenni a toggleDarkMode() metódust, amely a dark/light state-et módosítja és elmenti.

A Beállítások képernyőn (settings) jelenjen meg egy SwitchListTile komponens, amely a ThemeService darkMode állapotát mutatja, és módosítja azt.

A váltás Riverpod/Provider/Consumer logika mentén rebuildeli az egész UI-t (MaterialApp theme/darkTheme).

A kiválasztott dark mód azonnal alkalmazódik minden widgetre, nincs szükség újraindításra.

A választott dark/light állapot perzisztensen mentődik (T3.1), minden app induláskor visszatöltődik.

Minden változás automatikusan szinkronizálódik, ha a user be van jelentkezve.

🧪 Tesztállapot
Manuális teszt: Kapcsoló állásának változtatása minden skin-nel helyesen működik.

Automata teszt: Unit/widget teszt igazolja, hogy a ThemeService.toggleDarkMode() helyesen vált, ment, visszatölt.

CI pipeline minden tesztet zölden enged át.

🌍 Lokalizáció
A “Sötét mód” kapcsoló felirata magyar és angol nyelven jelenjen meg (localization szükséges).

Hibaüzenetek, státuszok szintén többnyelvűek, ha előfordulnak.

📎 Kapcsolódások
T3.1: A perzisztencia logikát használja

T3.3–T3.6: Minden további lépés a ThemeService darkMode állapotára épít

Beállítások képernyő: SwitchListTile UI-elem integrációja

CI pipeline: Automatikus teszt és audit kapcsolódik hozzá