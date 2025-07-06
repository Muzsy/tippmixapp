# BrandColors ThemeExtension

---

🎯 **Funkció**

A BrandColors ThemeExtension célja, hogy a TippmixApp alkalmazás minden egyedi, márkaspecifikus (nem szabványos ColorScheme) színét központilag, típusbiztosan tároljuk. A rendszer támogatja a különböző skineket és a dark/light módot, és biztosítja, hogy minden widget kizárólag ThemeExtension-ből használjon márka- vagy speciális színt. A konkrét színértékek külön fájlba szervezettek, így bővíthetők és karbantarthatók.

---

🧠 **Fejlesztési részletek**

- Hozd létre a `lib/theme/brand_colors.dart` fájlt, benne a BrandColors ThemeExtension definíciójával (pl. gradientStart, gradientEnd).
- Hozd létre a `lib/theme/brand_colors_presets.dart` fájlt, amely tartalmazza a konkrét színértékeket (brandColorsLight, brandColorsDark, skin-bővíthető).
- A ThemeBuilder a megfelelő presetet adja hozzá ThemeData.extensions-hoz (mind light, mind dark módban).
- Minden widget, amely ilyen színt használ, csak Theme.of(context).extension<BrandColors>()-en keresztül érheti el azt.
- A színértékek igazodjanak a FlexScheme.dellGenoa palettához, illetve legyenek bővíthetőek új skin hozzáadásakor.

---

🧪 **Tesztállapot**

- Ellenőrizd, hogy ThemeExtension mindig elérhető minden widget számára.
- Widget szintű unit tesztek: csak extension-ből jöhet brand-szín.
- Preset fájlban minden skinhez külön példány szerepel, dark/light móddal.
- Nincs hardcoded szín widgetben – ezt linter is tiltja.

---

🌍 **Lokalizáció**

- A ThemeExtension nem tartalmaz lokalizálható szöveget.
- Ha egyedi skin neveket, leírásokat használunk, azok külön lokalizációs fájlban jelennek meg.

---

📎 **Kapcsolódások**

- **ThemeBuilder**: a buildTheme() hívja meg a megfelelő presetet.
- **Widgetek**: minden egyedi színt csak extension-ből használnak.
- **FlexColorScheme**: a presetek színértékeit a skinből származtatjuk.
- **Jövőbeli skinek**: új presetek csak a brand_colors_presets.dart fájlt bővítik.

---
