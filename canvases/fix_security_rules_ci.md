# Firestore Security Rules CI integráció véglegesítése (Sprint5)

🎯 **Cél:**  
A Firestore security rules minden PR/branch esetén automatikusan, gyorsan, megbízhatóan tesztelve legyen a CI pipeline-ban. A teljes futási log mentésre kerül, a szabályok megsértése esetén a build automatikusan leáll.

🧠 **Fejlesztési részletek:**  
- Node 20+ pipeline (adott)
- Firestore emulator és npm package cache a gyorsabb futás érdekében
- Tesztszkriptek (`scripts/test_firebase_rules.sh`) automatikus futtatása minden buildben
- Minden teszteredmény (log, pass/fail) artifactként mentve
- Dokumentáció (README/devdoc) frissítése magyarul: mikor, hogyan fut, hol nézhetők a logok/artifactok

🧪 **Tesztállapot:**  
- Sikeres futás = minden security rules teszt PASS (build zöld)
- Sikertelen futás = azonnali build fail (hibalog, ok látható)
- Buildidő cél: <3 perc, CI gyorsítása cache-eléssel

📎 **Kapcsolódó fájlok:**  
- `firebase.rules`
- `scripts/test_firebase_rules.sh`
- `test/security_rules.test.mjs`
- `.github/workflows/ci.yaml`
---
