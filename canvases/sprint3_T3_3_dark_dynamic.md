🎯 Funkció
A felhasználó a Beállítások menüben könnyen válthat a különböző előre definiált skin-ek között. A skin-választó egy vizuális lista (ListView), ahol minden skinhez thumbnail (preview) is tartozik. A lista csak a projekt által engedélyezett FlexScheme-eket tartalmazza, minden váltás azonnal érvényesül, és a választás perzisztensen mentődik (T3.1/T3.2).

🧠 Fejlesztési részletek
UI megvalósítás:

A Beállítások képernyőn egy ListView vagy ListTile csoport jelenik meg, ahol minden elem egy skin-t (FlexSchemeData) reprezentál.

Minden skin ListTile-hez tartozik egy preview (például a FlexColorWheel vagy egyedi preview widget).

A jelenleg aktív skin meg van jelölve (pl. pipával vagy kiemeléssel).

Interakció:

A lista elemeire kattintva (onTap) a ThemeService setScheme(index) hívódik, amely azonnal frissíti a skin-t.

Az állapot Riverpod/Provider/Consumer mintán frissül.

Adatforrás:

Csak az előre definiált, auditált skinek jelennek meg, a ThemeService/ThemeBuilder availableThemes listája alapján.

Perzisztencia:

A választás azonnal mentésre kerül SharedPreferences-be, illetve bejelentkezett felhasználónál Firestore-ba is.

Preview lokalizáció:

Skin nevek, leírások minden nyelven megjelennek (localization szükséges).

🧪 Tesztállapot
Manuális teszt: minden skin-váltás azonnal érvényesül, preview helyes, a kiválasztott elem kiemelt.

Automata teszt: widget/integációs teszt a skin-választóra, ThemeService state helyes működése.

Minden teszt CI pipeline-ban zöld.

🌍 Lokalizáció
Skin nevek és leírások teljesen lokalizálva (magyar, angol, stb.).

Lista és UI elemek minden támogatott nyelven megjelennek.

📎 Kapcsolódások
T3.1–T3.2: Perzisztencia és dark mode váltás logika.

ThemeService: Skin váltás, availableThemes adatforrás.

Settings képernyő: UI integráció.

CI pipeline: automata teszt, audit kapcsolódik hozzá.

