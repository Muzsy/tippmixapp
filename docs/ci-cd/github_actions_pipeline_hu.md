version: "2025-08-11"
last_updated_by: codex-bot
depends_on: []

# 🚀 GitHub Actions CI/CD pipeline (HU)

Ez a dokumentum a TippmixApp GitHub Actions alapú folyamatos integrációs és kiadási folyamatát írja le.

---

## ⚙️ Célok

- Automatikus tesztelés minden push / PR esetén
- Dokumentáció minőségének ellenőrzése
- Backend infrastruktúra és Cloud Functions kihelyezése

---

## 🧩 Felépítés

Fő konfigurációs fájlok:

```
.github/workflows/main.yaml      # Flutter CI
.github/workflows/deploy.yml     # Backend infra + function
```

Alap lépések:

1. Repo klónozása
2. Flutter környezet beállítása
3. `flutter pub get` futtatása
4. `flutter analyze` ellenőrzés
5. `flutter test` tesztelés
6. Markdown + link ellenőrzés

---

## 🧪 Minőségi követelmények

- Minden teszt lefusson (`flutter test`)
- Lefedettség min. 80% (TODO: coverage script)
- Markdown fájlokban ne legyen törött link
- Ne kerüljön be hardcoded secret a verziókezelésbe

---

## 🧰 Javasolt eszközök

- [`actions/setup-flutter`](https://github.com/marketplace/actions/setup-flutter)
- \[`peaceiris/actions-mdbook`]\(dokumentáció build később)
- `markdownlint`, `markdown-link-check`

---

## 🚀 Backend deploy workflow

A `.github/workflows/deploy.yml` a `dev` és `main` branch-ekre érkező push esetén fut:

1. Node 20 beállítása npm cache-sel.
2. `firebase-tools@^13` telepítése.
3. `cloud_functions/lib` maradék build artefaktok törlése.
4. Függőségek telepítése és build futtatása: `npm ci --prefix cloud_functions` majd `npm run build --prefix cloud_functions`.
5. Firestore rules deploy a gyökér `firebase.rules` fájlból.
6. Cloud Functions deploy explicit projektválasztással.
7. Terraform no-op plan futtatása (`terraform init -backend=false && terraform validate && terraform plan`).

A szükséges GitHub Secret-eket lásd a [README-ci.md](../../README-ci.md) fájlban.

---

## 🚧 Tervezett bővítések

- Firebase Test Lab integráció (instrumented test)
- Codemagic integráció APK buildre (opcionális)
- Dokumentáció GitHub Pages-re (MkDocs-szal)
- Pre-push hook: YAML ellenőrzés + helyi lint futtatás
