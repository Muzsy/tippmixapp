🎯 Funkció
A T2.2 feladat célja, hogy a Sprint0-ban elkészült color_audit.csv fájlt használva, soronként manuálisan átnézzük a projekt összes manuális színhasználatát (beleértve a hex, rgb, Colors.* típusú előfordulásokat is). Minden sort hozzá kell rendelni a megfelelő Theme-referenciához, és ki kell emelni a nem automatikusan refaktorálható, speciális eseteket (pl. gradient, chart, bonyolult színlogika).

🧠 Fejlesztési részletek
Használat:

A color_audit.csv fájlt nyisd meg.

Minden sort vizsgálj meg, és rendeld hozzá, hogy milyen Theme.of(context).colorScheme.* vagy ThemeExtension értékre kell refaktorálni.

Azokat a sorokat, amelyek csak manuálisan vagy speciális logikával javíthatók (pl. összetett komponensek, több szín együtt, nem trivialis mapping), jelöld ki, ezek a T2.4 feladat részei lesznek.

A feldolgozás eredményét mentsd el új fájlba (pl. color_audit_reviewed.csv), ahol a mapping és a megjegyzések is szerepelnek.

Elfogadási kritériumok:

Minden előfordulás átnézve, Theme-referencia vagy ThemeExtension hozzárendelve.

Manuális javítás igénye kiemelve.

Az új csv lista világosan mutatja, hogy hol lesz automata csere, és hol manuális.

🧪 Tesztállapot
A color_audit_reviewed.csv minden sort tartalmaz és mappingolt.

Manuális ellenőrzés, hogy minden Colors.* és hard-coded szín szerepel a listában.

🌍 Lokalizáció
A folyamat fejlesztői, nem érint felhasználói lokalizációt.

📎 Kapcsolódások
Előzmény: Sprint0 color_audit.csv generálása.

Következő lépés: T2.3 (automata csere/codemod), T2.4 (manuális refaktor).

Linter tiltás, golden/a11y frissítés ez után történik.