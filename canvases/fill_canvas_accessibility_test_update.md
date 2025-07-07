# Accessibility audit pipeline – accessibility_tools → accessibility_test átállás

🎯 Funkció  
A feladat célja, hogy a teljes accessibility audit folyamat átálljon az accessibility_tools csomagról a hivatalos, Dart-alapú accessibility_test csomagra. Az új workflow automatikusan fut accessibility auditot a tesztek során, és blokkol minden hibás buildet. A váltás után a pipeline teljesen standardizált, CI-kompatibilis és könnyen karbantartható lesz.

🧠 Fejlesztési részletek  
- Az accessibility_tools csomag elhagyása: a pubspec.yaml-ban már nem szerepel, ezt előzetesen beállítottad.
- A kódból minden AccessibilityTools widget és import eltávolítása (pl. MaterialApp.builder).
- Létrejön egy új widgetteszt: test/accessibility_test.dart, amely accessibility auditot futtat a fő képernyőn az accessibility_test csomaggal.
- A teszt CI-barát: minden accessibility error automatikus hibát dob a pipeline-ban.
- Az új audit workflow teljesen Dart-alapú, nem igényel külső binárist.

🧪 Tesztállapot  
A build csak akkor sikeres, ha a test/accessibility_test.dart teszt accessibility error nélkül fut végig.

🌍 Lokalizáció  
Az accessibility_test audit nem érinti közvetlenül a lokalizációs logikát, de minden felhasználói szöveg és alt label kötelezően lokalizált.

📎 Kapcsolódások  
- Előzmény: Sprint2 accessibility_tools audit, accessibility_tools widgetek.
- Következő: Minden jövőbeli accessibility audit, Codex QA, Golden tesztek, linter.
