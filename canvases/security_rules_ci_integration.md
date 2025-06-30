canvases/security_rules_ci_integration.md
🎯 Funkció
A Firestore security rules automatizált CI/CD pipeline-ba integrálása.
Cél: minden push/PR esetén a coin_logs és kapcsolódó kollekciók szabályainak teljes tesztelése, hibás szabály vagy hozzáférés esetén a pipeline azonnal bukjon. Node-emulátor alapú tesztrendszer használata, output badge generálás a README-hez.

🧠 Fejlesztési részletek
Előkészítés:

A scripts/test_firebase_rules.sh script helyi futtatása (Node emulátor telepítve, dependenciák rendben).

Ellenőrizni kell, hogy minden új/bővített szabályra van teszt.

CI integráció:

.github/workflows/ci.yaml fájlban új lépés a security rules tesztre (run: ./scripts/test_firebase_rules.sh).

Node környezet setup: dependency letöltés (npm install), cache-elés.

Pipeline fail, ha a rules-teszt hibát talál.

Optimalizáció:

Dependency cache-elés, emulátor csak szükség esetén töltődjön le.

Build idő <3 perc maradjon.

Badge generálás:

Teszt badge kimenet frissítése, automatikusan update README-ben.

Dokumentáció:

Rövid leírás, coverage output, pipeline log hozzáfűzése a projekt wikihez.

🧪 Tesztállapot
scripts/test_firebase_rules.sh helyben fut, minden teszt zöld.

CI pipeline minden branch/PR-n fut, hibára bukik.

Lefedettség: minden coin_logs access rule, minden releváns Firestore collection.

🌍 Lokalizáció
Tesztelés nyelvfüggetlen, de a badge, log output minden csapattag által értelmezhető.

README-badge angol/magyar felirattal, pipeline output auditálható.

📎 Kapcsolódások
Kapcsolódó fájlok: scripts/test_firebase_rules.sh, firestore.rules, .github/workflows/ci.yaml

Függőség: Node.js, npm, firebase-tools, Firestore emulator, GitHub Actions.