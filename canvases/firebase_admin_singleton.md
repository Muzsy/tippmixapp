## 🛠️ Firebase Admin inicializálás refaktor – **singleton** megoldás

### 🎯 Cél

Szűnjön meg a `duplicate-app` runti­­me‑/build‑hiba, amely akkor lép fel, ha ugyanabban a Node‑processzben több `initializeApp()` hívás fut. 

* **Egységes, egyszeri** inicializálás a `cloud_functions` kódbázisban.
* Könnyen importálható `db` példány (Firestore) minden modulban.
* CI és lokális script‑futtatás is hibamentes.

---

### 🔎 Háttér (probléma)

* Jelenleg **minden** Function‑entrypoint és admin‑script ezt használja:

  ```ts
  import * as admin from 'firebase-admin';
  admin.initializeApp();
  const db = admin.firestore();
  ```
* A Functions builder static‑analysis közben már ütköznek ezek – `Error: The default Firebase app already exists …` → **deploy meghiúsul**.

---

### 💡 Megoldás

1. **Új központi modul** `src/lib/firebase.ts` (TypeScript):

   ```ts
   import { getApps, initializeApp, applicationDefault } from 'firebase-admin/app';
   import { getFirestore } from 'firebase-admin/firestore';

   if (!getApps().length) {
     initializeApp({ credential: applicationDefault() });
   }

   export const db = getFirestore();
   ```
2. **Refaktor** minden érintett fájlban:

   * Töröld a `import * as admin …` blokkot.
   * Cseréld le `const db = admin.firestore();` → `import { db } from './lib/firebase';` (útvonalat igazítsd).
3. **Frissítsd** a `cloud_functions/package.json`‑t:

   ```json
   "engines": { "node": "20" },
   "dependencies": {
     "firebase-admin": "^12",  // latest LTS
     "firebase-functions": "^4"
   }
   ```
4. **Build & CI**

   * `npm ci --prefix cloud_functions && npm run --prefix cloud_functions build` – TS → JS.
   * GitHub Actions‑ban már van „Compile Cloud Functions” lépés – az most zöld lesz.
5. **Deploy / lokális teszt**

   * Lokálisan: `npm run --prefix cloud_functions migrate:user-schema` → nem lesz duplicate‑app.
   * Prod: `firebase deploy --only functions`.

---

### 🧪 Tesztelés

* **Unit**: mockold a `getApps()`‑t, ellenőrizd, hogy második import nem hívja újra `initializeApp()`‑et.
* **E2E**: `firebase emulators:start` + migrációs script lefuttatása; logban nem jelenhet meg `app/duplicate-app`.
* **CI**: GitHub Actions futtatás – `Compile Cloud Functions` lépés SUCCESS.

---

### ⏳ Becsült ráfordítás

| Task                  | Idő        |
| --------------------- | ---------- |
| Új modul + refaktor   | 15‑20 perc |
| CI & build ellenőrzés | 5 perc     |
| Deploy + validáció    | 5‑10 perc  |

> **Kész kimenet**: új `src/lib/firebase.ts`, módosított importok, frissított `package.json`. CI‑pipeline zöld, Functions deploy sikeres.
