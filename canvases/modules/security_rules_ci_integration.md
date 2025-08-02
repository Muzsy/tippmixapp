# 🧪 Security Rules CI Integráció

🎯 **Funkció**

A Firestore biztonsági szabályok (security rules) folyamatos integrációs (CI) pipeline‑be illesztése, hogy minden módosítás után automatikusan lefussanak a szabálytesztek és hibás konfiguráció esetén meghiúsuljon a build【745379437967261†L1-L24】.

🧠 **Felépítés**

- **Tesztfuttató script**: A `scripts/test_firebase_rules.sh` script emulátorban futtatja a Firestore szabályok tesztjeit `firebase emulators:exec` segítségével. A script mind a Node‑os, mind a Flutteres tesztekre hivatkozik, és jelenti az esetleges hibákat.
- **GitHub Actions workflow**: A `.github/workflows/ci.yaml` fájl bővül egy lépéssel, amely meghívja a fenti scriptet. A workflow cache‑eli a Node modulokat, előtelepíti az emulátorokat, majd futtatja a teszteket és generál coverage badge‑et【745379437967261†L20-L24】.
- **Egyéb módosítások**: A pipeline optimalizálása érdekében a workflow külön lépésben futtatja a Flutter teszteket és a szabályteszteket, hogy a buildidő csökkenjen.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_security_rules_ci_integration.yaml` – a részletes célokat és feladatlistát tartalmazza【745379437967261†L1-L24】.

🐞 **Fixek és tanulságok**

A CI integráció során korábban felmerült hibákat az [Archivált fix](../_archive/fixes/fix_security_rules_ci.md) dokumentálja. A jelen modul arra szolgál, hogy a végleges, rendezett megoldást és a pipeline lépéseit rögzítse.

🧪 **Tesztállapot**

A modul sikeres bevezetése után a CI workflow‑ban futó szabálytesztek zölden kell hogy lefussanak. A tesztek törés esetén sikertelen buildet eredményeznek. A tesztek megfelelnek a [Security Rules – coin_logs](security_rules_coin_logs.md) modulban leírt feltételeknek is.

📎 **Modul hivatkozások**

- [Security Rules – coin_logs](security_rules_coin_logs.md) modul – a tesztek alapját képező szabályok.
- `.github/workflows/ci.yaml` – a CI konfiguráció.
