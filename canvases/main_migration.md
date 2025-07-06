# main.dart migráció (ThemeBuilder + ThemeService bekötés)

---

🎯 **Funkció**

A main.dart migráció célja, hogy a teljes TippmixApp alkalmazás a modern FlexColorScheme-alapú ThemeBuilder-t és a ThemeService állapotkezelést használja. A színséma és skin kezelés ezentúl központilag, dinamikusan történik – a main.dart csak a ThemeBuilder által generált ThemeData-t alkalmazza, és minden theme-váltás a ThemeService-ből indul ki.

---

🧠 **Fejlesztési részletek**

- Nyisd meg a `lib/main.dart` fájlt.
- Cseréld le a MaterialApp `theme` és `darkTheme` property-jeit úgy, hogy azokat a ThemeBuilder (buildTheme) szolgáltassa.
- Kösd be a ThemeService-t mint provider a fő widgetfában, hogy az egész app tudja figyelni a theme/skin állapotot.
- A theme és darkTheme paraméterek mostantól mindig dinamikusan frissülnek, ha a ThemeService-ben változik a skin vagy a mód.
- Ne maradjon semmilyen hardcoded vagy régi ThemeData, csak ThemeBuilder és ThemeService lehet használatban.
- Dokumentálj a kódban minden fő változást, különösen a skin index/dark mode figyelést.

---

🧪 **Tesztállapot**

- Manuális/automata teszt: minden theme/skin/dark váltás azonnal megjelenik az appban, state rebuild nélkül.
- Widget tesztek: az app minden fő UI eleme megkapja az új ThemeData-t.
- Nincs elavult vagy hardcoded theme hivatkozás.

---

🌍 **Lokalizáció**

- A main.dart migráció közvetlenül nem érinti a lokalizációt.
- A skin nevek/paraméterek lokalizációja a ThemeService-hez tartozik.

---

📎 **Kapcsolódások**

- **ThemeBuilder**: a fő ThemeData generálása innen történik.
- **ThemeService**: az app állapotát és skinjét kezeli.
- **BrandColors**: ThemeData extensions paraméterével kerül hozzáadásra.
- **Minden UI/Widget**: közvetlenül a Theme.of(context)-ből kapja a színeket.

---
