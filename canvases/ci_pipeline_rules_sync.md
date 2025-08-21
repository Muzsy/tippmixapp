# CI pipeline finomítás + Rules szinkron

🎯 **Funkció**
A GitHub Actions deploy pipeline kiegészítése és a Firestore Rules forrásának kanonizálása. Cél: (1) Firestore rules automatikus deploy a functions előtt, (2) stale build védelem a Cloud Functionshez, (3) Firebase‑es deploy ellenőrzés az infra tesztben, (4) no‑op Terraform plan a deploy végén, (5) README pontosítás a kanonikus rules forrásról, (6) minőségjavítások (Node 20 cache, firebase‑tools pin).

---

🧠 **Fejlesztési részletek**

* **Kanonikus rules‑forrás:** `firebase.rules` a repo gyökerében. A `cloud_functions/firestore.rules` nem deploy forrás.
* **Deploy sorrend:**

  1. `rm -rf cloud_functions/lib` – régi build artefaktok törlése.
  2. `npm ci && npm run build` `cloud_functions` alatt.
  3. `firebase deploy --only firestore:rules` (gyökér `firebase.rules`).
  4. `firebase deploy --only functions` (Gen2, `europe-central2`).
  5. `terraform init -backend=false && terraform validate && terraform plan` (no‑op) a végén.
* **Minőségjavítások:** `actions/setup-node@v4` npm cache, `firebase-tools@^13` (pinelt major), explicit projektválasztás (dev/prod) a meglévő `MODE` logika szerint.
* **Rules drift javítás:** `firebase.rules` alatt a `coin_logs` írás **tiltva** (legacy), csak olvasás saját rekordokra. A `cloud_functions/firestore.rules` fájl maradhat referenciának, de README rögzíti, hogy **nem** ez a deploy forrás.

---

🧪 **Tesztállapot**

* **CI (ci.yaml):** fut; a változások a `deploy.yml`‑t érintik.
* **Rules teszt:** `scripts/test_firebase_rules.sh` a CI‑ban már fut; a deployba nem kötelező, de opcionálisan beköthető gyors sanity checkként.
* **Infra teszt:** `infra/test/deploy_workflow.spec.ts` módosul: Firebase‑es deploy stringet vár, és ellenőrzi a `firestore:rules` deployt is; `terraform plan` is kötelező marad a deploy workflow végén (no‑op backend nélkül).

---

🌍 **Lokalizáció**
Nincs felhasználói UI‑szöveg; README módosítás angolul maradhat a repo egységessége érdekében.

---

📎 **Kapcsolódások**

* **/docs, /codex\_docs:** a Codex Canvas Yaml Guide alapján készül a YAML.
* **Cloud Functions:** Node 20, Gen2, régió: `europe-central2`.
* **Security Rules:** a deploy mindig a gyökér `firebase.rules`‑t viszi fel.

---

**Megjegyzés:** Ez a vászon a legutóbb feltöltött `tippmixapp.zip` kódjára készült. A YAML lépései pontos diffeket tartalmaznak a jelenlegi fájlokra igazítva.
