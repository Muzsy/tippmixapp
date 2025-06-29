# Firestore Security Rules CI Integráció

🎯 Funkció
Biztonsági szabályok automatikus tesztelése a CI pipeline részeként. Cél: csak a helyesen konfigurált hozzáférések engedélyezettek, minden pénzügyi tranzakció védett és naplózott.

🧠 Fejlesztési részletek
- scripts/test_firebase_rules.sh: Node környezetben futó security.rules teszt script (Node-emulátor).
- .github/workflows/ci.yaml: pipeline-ba integrált tesztfuttatás, Node dependency cache alkalmazásával.
- Coverage badge generálás és automatikus frissítés a README.md-ben.
- A pipeline csak akkor zöld, ha minden security rules teszt sikeres.
- Tesztfuttatás eredménye magyar/angol üzenettel a CI logban.

🧪 Tesztállapot
- Node-emulátor tesztek (security_rules.test.mjs) automatikusan futnak CI-ben.
- Kimenet: 100% pass → pipeline zöld, coverage badge frissül.
- Hiba esetén pipeline blokkolt, részletes hibaüzenet a logban.

🌍 Lokalizáció
- CI log magyar és angol üzeneteket tartalmaz (siker, hiba).
- Coverage badge magyarázat README.md-ben mindkét nyelven.

📎 Kapcsolódások
- firestore.rules (backend security policy)
- coin_logs, transaction_wrapper (pénzügyi integrity)
- Codex workflow: vászon + yaml (generált tesztfájlok)
- scripts/test_firebase_rules.sh, .github/workflows/ci.yaml, README.md
