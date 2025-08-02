# 🏟️ TippmixApp

![Lefedettség](./badges/coverage.svg)
[![Coverage Status](https://codecov.io/gh/Muzsy/tippmixapp/branch/main/graph/badge.svg)](https://codecov.io/gh/Muzsy/tippmixapp)
[![Security Rules Coverage](coverage/security_rules_badge.svg)](coverage/security_rules_badge.svg)
[![CI](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml/badge.svg)](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml)

A TippmixApp egy moduláris Flutter alkalmazás, amely közösségi alapú sportfogadás szimulációjára épül.
TippCoin virtuális gazdaságot, valós idejű OddsAPI-integrációt, Firebase backendet és Codex-alapú fejlesztési munkafolyamatot tartalmaz.

![Bejelentkezés képernyő](docs/images/login_revamp_screenshot_v1.png)

---

## 🚀 Funkciók

- **Firebase autentikáció** – email/jelszavas bejelentkezés és regisztráció
- **TippCoin gazdaság** – tétek, nyeremények, tranzakciónapló (CoinService tervben)
- **Firestore backend** – felhasználók, szelvények, badge-ek, ranglista kezelése
- **OddsAPI integráció** – sportesemények és szorzók valós időben
- **Szelvény munkafolyamat** – tippek hozzáadása, szelvény beküldése
- **Gamifikáció** – badge-ek, ranglista, közösségi feed (terv)
- **Fórum modul** – felhasználói beszélgetések, szálak és válaszok (terv)
- **Push értesítések** – FCM-en keresztül fontos eseményekről
- **GoRouter navigáció** és ARB-alapú lokalizáció enum kulcsokkal
- **Témakezelés** – világos/sötét mód FlexColorScheme segítségével
- **Widget + golden tesztek** – CI-vezérelt minőségbiztosítás

---

## 🧪 Indítás lépései

1. Telepítsd a [Flutter](https://docs.flutter.dev/get-started/install) 3.10.0 vagy újabb verzióját
2. Futtasd: `flutter pub get`
3. Hozd létre a `.env` fájlt a projekt gyökérkönyvtárában:

   ```bash
   ODDS_API_KEY=ide_írd_a_saját_kulcsod
   ```

4. Állítsd be a Firebase-t (`google-services.json`, `GoogleService-Info.plist`)
5. Indítsd az appot:

   ```bash
   flutter run
   ```

6. Tesztelés futtatása:

   ```bash
   flutter test
   ```

---

## 🗂️ Könyvtárstruktúra

| Könyvtár       | Tartalom                                            |
| -------------- | --------------------------------------------------- |
| `lib/`         | Alkalmazás logika: képernyők, szervizek, providerek |
| `test/`        | Widget, szerviz, golden és integrációs tesztek      |
| `docs/`        | Technikai dokumentáció angol és magyar nyelven      |
| `codex_docs/`  | Codex szabályfájlok (`*_en.md`, `*_en.yaml`)        |
| `canvases/`    | Codex vászonfájlok                                  |
| `codex/goals/` | Codex feladatleíró YAML fájlok                      |
| `legacy/`      | Elavult komponensek (pl. régi AppColors osztály)    |

---

## 📚 Dokumentációs térkép

A `docs/` alatti fájlok részletes áttekintést adnak az alkalmazás működéséről.
Csak az angol fájlokat (`*_en.md`) használja a Codex.

### 🔨 Backend logika

- `docs/backend/data_model_en.md`
- `docs/backend/coin_service_logic_en.md`
- `docs/backend/security_rules_en.md`

### 🎯 Főbb funkciók

- `docs/features/leaderboard_logic_en.md`
- `docs/features/badge_system_en.md`
- `docs/features/feed_module_plan_en.md`
- `docs/features/forum_module_plan_en.md`
- `docs/features/push_notification_strategy_en.md`

### 💡 Frontend működés

- `docs/frontend/auth_strategy_en.md`
- `docs/frontend/localization_best_practice_en.md`
- `docs/frontend/theme_rules_en.md`

### 📐 Architektúra és QA

- `docs/architecture/architecture_overview_en.md`
- `docs/qa/golden_workflow_en.md`
- `docs/ci-cd/github_actions_pipeline_en.md`

Minden dokumentumhoz tartozik `_hu.md` fordítás emberi olvasásra.

---

## 🎨 Téma és színezés

A szín- és betűtípus-stílusokat a `BrandColors` és a `FlexColorScheme` határozza meg.
Kerüld az `AppColors` használatát – ez csak referenciaként érhető el a `legacy/AppColors.dart` fájlban.
Minden widget a `Theme.of(context)` által szolgáltatott színeket használja.

---

## 🛡️ CI: Firestore biztonsági szabályok

A GitHub Actions workflow automatikusan futtatja a `scripts/test_firebase_rules.sh` scriptet,
amely a Firebase Emulatort és a `test/security_rules.test.mjs` tesztet.
Az eredmények a `security_rules_test.log` fájlba kerülnek és `security-rules-log` néven feltöltésre kerülnek.

---

## 👤 Avatar képek

Az avatar képeket kézzel kell bemásolni az `assets/avatar/` mappába. Bináris fájlokat nem szabad verziókövetésbe tenni.
Alapértelmezett avatar: `assets/avatar/default_avatar.png`

---

A Codex konfigurációját lásd: [`AGENTS.md`](./AGENTS.md)
