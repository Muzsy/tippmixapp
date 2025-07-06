Sprint4 T4.1 – Golden matrix script (QA & Accessibility)
🎯 Funkció
Automatizált golden baseline screenshot generálás minden skin × világos/sötét mód × főképernyő kombinációra, hogy a TippmixApp színsémarendszere vizuálisan auditált, visszakereshető és CI pipeline által folyamatosan ellenőrzött legyen.

🧠 Fejlesztési részletek
Készítsd el vagy frissítsd a generate_goldens.dart scriptet, amely automatikusan végigiterál az összes elérhető skin-en és módon, minden fő route-ra screenshotot készítve.

A PNG fájlokat a /test/goldens/ mappába exportálja – a generálást és commitot kizárólag manuálisan, fejlesztőként végzed el!

Codex csak a scriptet, teszteket, workflow-t készítheti el; bináris generálás/commit mindig manuális!

A PNG-k naprakészsége elengedhetetlen: minden PR pipeline diff-et futtat, eltérés esetén blokkol.

Fájlnév-konvenció: {screen}_skin{index}_{light|dark}.png

🧪 Tesztállapot
A golden baseline minden kombinációban létezik.

Pipeline-ban minden diff 0, commit warningmentes.

PNG-k generálása és commitálása manuális.

🌍 Lokalizáció
Fájlnevek és workflow nem érint lokalizációt.

Golden snapshot audit minden nyelvi beállítás mellett működik.

📎 Kapcsolódások
Minden további QA & accessibility pipeline workflow (T4.2–T4.7)

PNG-k naprakészsége minden minőségbiztosítás alapja.

⚠️ Kritikus szabály
Codex NEM generál és nem commitál bináris fájlt.

Minden golden PNG manuálisan kerül a repo-ba.