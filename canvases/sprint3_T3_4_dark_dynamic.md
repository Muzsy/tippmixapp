T3.4 – UI és ThemeService összekötése (élő skin-váltás)
🎯 Funkció
A cél, hogy a Beállítások képernyő skin selector UI-ja teljesen élő módon kapcsolódjon a ThemeService-hez: minden felhasználói interakció (skin-választás, dark mode kapcsoló) azonnal és globálisan frissítse az app kinézetét. A változás minden képernyőn azonnal megjelenik, nincs szükség újraindításra.

🧠 Fejlesztési részletek
A skin-választó UI elemei (ListTile, SwitchListTile) Consumer vagy Provider/Riverpod mintán figyelik a ThemeService állapotát.

Amikor a felhasználó skint vagy dark mode-ot vált, az onTap vagy kapcsoló ThemeService metódust hív (setScheme, toggleDarkMode).

A MaterialApp theme/darkTheme paraméterei is a ThemeService aktuális állapotából épülnek újra.

Minden képernyő (route) automatikusan frissül (hot reload), amikor a ThemeService state módosul.

Teszt: skin és dark/light váltás után a főbb képernyőkön ellenőrizhető a változás.

🧪 Tesztállapot
Manuális: minden skin és módváltás azonnal, globálisan érvényesül.

Automata: widget/integrációs teszt a skin/dark váltó interakciókra.

CI pipeline-ban minden teszt sikeres.

🌍 Lokalizáció
UI elemek lokalizáltak, minden státusz és visszajelzés a kiválasztott nyelven jelenik meg.

📎 Kapcsolódások
T3.1–T3.3: Perzisztencia, dark mode, skin selector UI.

ThemeService: Állapotkezelés.

Beállítások képernyő: Interaktív UI logika.

MaterialApp: theme paraméter összekötése state-tel.

Tesztelés: Widget- és integrációs tesztek kapcsolódnak hozzá.