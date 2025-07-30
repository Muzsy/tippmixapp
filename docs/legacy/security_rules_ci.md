# Firestore Security Rules CI folyamat

A TippmixApp minden PR es `main` branch push eseten automatikusan ellenorzi a Firestore biztonsagi szabalyokat.
A `.github/workflows/ci.yaml` workflow a kovetkezo lepeseit hajtja vegre:

1. Node.js 20 kornyezetet allit fel es cache-eli az `~/.npm` valamint
   `~/.cache/firebase/emulators` mappakat a gyorsabb futas erdekeben.
2. A `scripts/test_firebase_rules.sh` script telepiti az npm fuggosegeket
   (`npm ci --prefer-offline`), majd a Firestore Emulator inditasaval lefuttatja
   a `npm run test:rules:coverage` parancsot.
3. A tesztek kimenete a `security_rules_test.log` fajlba kerul, amit a CI
   `security-rules-log` nevu artifactkent tarol.
4. Sikeres lefutas eseten frissul a `coverage/security_rules_badge.svg`
   jelveny. Hibas szabaly eseten a pipeline azonnal megszakad es a logban
   olvashatok a reszletek.

A logfajlok es a generalt badge a GitHub Actions feluleten erheto el.
