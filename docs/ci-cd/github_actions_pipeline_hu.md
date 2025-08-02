# 🚀 GitHub Actions CI/CD pipeline (HU)

Ez a dokumentum a TippmixApp GitHub Actions alapú folyamatos integrációs és kiadási folyamatát írja le.

---

## ⚙️ Célok

- Automatikus tesztelés minden push / PR esetén
- Dokumentáció minőségének ellenőrzése
- Későbbi kiadás előkészítése

---

## 🧩 Felépítés

Fő konfiguráció:

```
.github/workflows/main.yaml
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

## 🚧 Tervezett bővítések

- Firebase Test Lab integráció (instrumented test)
- Codemagic integráció APK buildre (opcionális)
- Dokumentáció GitHub Pages-re (MkDocs-szal)
- Pre-push hook: YAML ellenőrzés + helyi lint futtatás
