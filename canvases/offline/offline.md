# TippmixApp — Offline fejlesztői környezet (production‑parity) feladatlista

Dátum: 2025-09-06
Fókusz: teljesen felhő nélküli fejlesztés **Firebase Emulator Suite**-tal, a lehető legnagyobb **production‑parity** céllal (viselkedés, jogosultságok, adatmodell, API‑réteg). A lista **pipálható**, minden ponthoz rövid leírás és elfogadási kritérium tartozik.

---

## 🎯 Funkció

Cél: A TippmixApp fejlesztése **offline** környezetben, úgy hogy a kliens‑ és szerveroldali viselkedés a lehető legjobban megközelítse a valós felhős működést. Nincs internet‑függés (külső API‑k, GCP), minden kritikus funkció emulátorral, stubbal vagy lokális mockkal kiváltható. Eredmény: fejlesztés, teszt és demó **felhőszámla nélkül**.

---

## ✅ Pipálható feladatlista (részletes)

### 1) Alap konfiguráció és profilok

* [ ] **`firebase.json` bővítése** Auth (9099), Firestore (8080), Storage (9199), Functions (5001), Emulator UI (4000) portokkal.
  *Miért:* minden érintett szolgáltatás lokálisan fusson.
  *Elfogadás:* `firebase emulators:start` indul, UI elérhető `http://localhost:4000`.
* [x] **Offline futási profil** bevezetése: `USE_EMULATOR=true`, `USE_MOCK_SCORES=true`, `USE_INLINE_FINALIZER=true`, `API_FOOTBALL_KEY=dummy` környezeti változók.
  *Miért:* egyetlen kapcsolóval offline mód.
  *Elfogadás:* `.env.local`/shell export alapján minden parancs ugyanazt a profilt használja.
* [x] **Dart define‑ok**: `--dart-define=USE_EMULATOR=true` alapértelmezett a dev futáshoz.
  *Elfogadás:* Flutter kliens az emulátorokra csatlakozik (lásd 3. pont).

### 2) Emulator stack telepítés és életciklus

* [x] **Telepítés & cache**: `npm ci` a projektgyökérben, `.emulator_data/` mappa az import/export állapothoz.
  *Elfogadás:* emulátorok indíthatók, állapot mentődik kilépéskor.
* [x] **Start script**: `npm run emu:start` → `firebase emulators:start --only auth,firestore,storage,functions --import=.emulator_data --export-on-exit`.
  *Elfogadás:* egy parancs indít, UI él.
* [x] **Stop/clean script**: `emu:stop` (SIGINT kezelése) és `emu:reset` (mentés törlése).
  *Elfogadás:* tiszta állapot egy paranccsal visszaállítható.

### 3) Flutter kliens bekötése az emukra

* [x] **Firebase init fájl frissítése** (pl. `lib/bootstrap.dart`): `useAuthEmulator`, `useFirestoreEmulator`, `useFunctionsEmulator`, `useStorageEmulator` host=Android: `10.0.2.2`, egyéb: `localhost`. Analytics **devben off**.
  *Elfogadás:* app induláskor nem próbál felhőre csatlakozni.
* [x] **Android cleartext engedély**: `AndroidManifest.xml` + `res/xml/network_security_config.xml` a `10.0.2.2`/`localhost` hívásokhoz.
  *Elfogadás:* Functions hívások nem esnek el cleartext miatt.
* [x] **App Check (debug)**: debug provider aktiválása devben, enforcement kikapcsolva.
  *Elfogadás:* App Check nem blokkolja az emulátoros hívásokat.

### 4) Cloud Functions (v2) — offline parity

* [x] **Külső API réteg cserélhetővé tétele**: `ApiFootballResultProvider` mögé **mock provider** (lokális JSON). Kapcsolás env‑vel: `USE_MOCK_SCORES=true`.
  *Elfogadás:* külső hálózat nélkül is végigmegy egy ticket kiértékelés.
* [x] **Finalizer Pub/Sub kiváltása fejlesztésben**: callable → **inline meghívás** (`USE_INLINE_FINALIZER=true`) Pub/Sub nélkül.
  *Elfogadás:* callable híváskor azonnal fut a finalizer emulátoron.
* [ ] **(Haladó) Pub/Sub emulátor út**: külön topic/trigger definíció devre; scheduler események szimulálása `functions:scheduler` támogatással (ha használjuk).
  *Elfogadás:* időzített logika manuális triggerrel próbálható (pl. `curl`/UI), *vagy* inline módban.
* [x] **Build/lint**: `npm ci && npm run build` a `cloud_functions/` alatt, typedef hibák nélkül.
  *Elfogadás:* emulator Functions feláll, endpointok regisztrálódnak.

### 5) Firebase Auth — valós használati minták emulálása

* [x] **Teszt felhasználók**: script a REST emu API‑val (email/jelszó) + opcionális custom claims (admin/role).
  *Elfogadás:* min. 3 szerepkör: normál user, moderátor, admin.
* [ ] **3rd‑party bejelentkezés szimuláció**: IdP helyett előre létrehozott fiókok + `providerId` jelzés / claims.
  *Megjegyzés:* valódi Google/Facebook IdP teljes áram nem emulálható; ezt claims‑szel közelítjük.
  *Elfogadás:* kliens oldali guardok ugyanúgy viselkednek, mint IdP‑s usernél.

### 6) Firestore — adatmodell, szabályok, indexek

* [x] **Rules és indexek betöltése**: `firebase.rules`/`firestore.indexes.json` használata emulátoron.
  *Elfogadás:* emulator UI‐ban a jogosultságok érvényesülnek.
* [x] **Seed adatok**: `tools/seed.ts` (admin SDK emu hosttal) — users, tickets, fixtures, leaderboard minimum adatkészlet.
  *Elfogadás:* app főképernyői „élő” adatot mutatnak emulátorral.
* [ ] **Rules‑tesztek**: `@firebase/rules-unit-testing` alapon unit tesztek P0 útvonalakra (olvasás/írás tiltások, saját dokumentumhoz kötött írások, stb.).
  *Elfogadás:* `npm test` zöld; regresszió esetén azonnal jelez.

### 7) Storage — avatarok és mellékletek

* [x] **Storage emu bekötés** a kliensben.
  *Elfogadás:* avatar feltöltés/olvasás emulátoron működik.
* [x] **Seed fájlok**: minta avatarok feltöltése (script vagy UI).
  *Elfogadás:* lista/letöltés szabályok szerint működik (deny/allow tesztelve).

### 8) Remote Config — helyettesítés production‑parity céllal

* [x] **Local RC adapter**: kulcs‑érték defaultok JSON‑ból (pl. `assets/rc_defaults.json`) + fetch skip devben, vagy rövid timeout cache‑szel.
  *Elfogadás:* RC‑t igénylő feature flag‑ek determinisztikusan működnek offline.
* [x] **Dokumentált flag‑mátrix**: táblázat a fő RC kulcsokról, defaultokról, és app‑viselkedésről.
  *Elfogadás:* fejlesztő tudja offline mit vár a kliens.

### 9) Analytics — lokális naplózás

* [x] **Analytics dev‑off** vagy **local sink**: események fájlba/Firestore gyűjteménybe logolása devben.
  *Elfogadás:* események nem mennek a felhőbe, de visszanézhetők (debug).

### 10) Seeder és adatkészlet (end‑to‑end próba)

* [ ] **End‑to‑end seed**: felhasználók + 2‑3 aktív/pending ticket + 1‑2 lezárt meccs mock eredménnyel + leaderboard snapshot.
  *Elfogadás:* appban bejelentkezés után azonnal látszik a teljes flow.

### 11) DX parancsok (egyparancsos élmény)

* [x] `npm run dev:offline` → emulátorok indítása + Functions build + seed + Flutter run `--dart-define=USE_EMULATOR=true`.
  *Elfogadás:* egy paranccsal indul a teljes offline kör.
* [x] `npm run emu:export` → állapotmentés; `emu:import` → visszaállítás.
  *Elfogadás:* determinisztikus demó állapot visszatölthető.

### 12) QA forgatókönyvek (E2E)

* [ ] **Belépés** tesztuserrel (email/jelszó).
  *Elfogadás:* sikeres login, user profil betölt.
* [ ] **Ticket létrehozás** (legalább 2 tipp).
  *Elfogadás:* ticket Firestore‑ban megjelenik, státusz `pending`.
* [ ] **Finalizer futtatás** (callable vagy inline).
  *Elfogadás:* ticket státusz frissül (win/lose/push) mock eredmény alapján.
* [ ] **Avatar feltöltés/olvasás** Storage emun.
  *Elfogadás:* kép elérhető szabályok szerint.
* [ ] **RC‑függő UI elem** (pl. variáns A/B) ellenőrzése defaultból.
  *Elfogadás:* elvárt variáns jelenik meg.

### 13) Védőkorlátok (nehogy véletlenül felhőre menjen)

* [x] **Build guard**: ha `USE_EMULATOR=true`, minden Firebase app `app.options.projectId`/host ellenőrzés → hibát dob, ha nem emu.
  *Elfogadás:* rossz profilnál a build/indítás megáll.
* [x] **Pre‑commit check**: tiltott URL‑ek grep (pl. `https://europe-central2...`) dev buildben.
  *Elfogadás:* PR‑ban nem csúszik be felhő endpoint dev kódban.

### 14) Dokumentáció & tudásátadás

* [x] **Offline Playbook** (README szekció): parancsok, környezeti változók, gyakori hibák, elfogadási lépések.
  *Elfogadás:* új fejlesztő 30 perc alatt be tud állni offline.
* [x] **Troubleshooting**: Android cleartext, eszköz‑LAN IP, Functions logok, Auth REST minták.
  *Elfogadás:* tipikus hibákra van azonnali válasz.

### 15) Elfogadási checklist (végső)

* [ ] **Netkapcsolat bontva** (Wi‑Fi off) — emulátorokkal minden QA forgatókönyv lefut.
* [ ] **Semmilyen külső API hívás** nem történik (proxy/mitm ellenőrzés).
* [x] **Adatállapot exportálható** és újragyártható `emu:export`/`emu:import`‑tal.
* [ ] **Build guardok** megfogják a rossz profilokat.

---

## 🧠 Fejlesztési részletek (közeli production‑parity)

* **IdP korlát**: Google/Facebook bejelentkezés teljes folyamata nem emulálható; claims‑alapú szimulációval közelítjük a jogosultsági viselkedést.
* **Scheduled/queue feladatok**: fejlesztésben inline hívással determinisztikusabb; haladó módban Pub/Sub emu + manuális trigger (stabilitás vs. realizmus döntés kérdése).
* **Remote Config/Analytics**: hivatalos emu nincs; helyettesítés defaultokkal illetve lokális logolóval.

---

## 🧪 Tesztállapot

* **Rules‑tesztek**: P0 olvasás/írás útvonalak lefedve.
* **Functions unit**: mock providerrel, külső hívások nélkül.
* **Kliens widget/unit**: hálózat nélküli futás biztosított (fake/mocked rétegek).
* **E2E kézi**: 12) pont szerinti forgatókönyvek.

---

## 🌍 Lokalizáció

* Offline mód nem igényel új nyelvi kulcsokat. Dokumentáció HU, kódban meglévő i18n változatlan.

---

## 📎 Kapcsolódások

* Firestore/Storage rules és index fájlok (projekten belül).
* Cloud Functions v2 kód (API provider réteg, finalizer, callable endpointok).
* Kliens Firebase init (emulátor kötés, analytics off).
* Seed scriptek és DX parancsok (npm run …).
