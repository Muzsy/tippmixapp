# Legacy Code Cleanup & CI Hardening – Sprint 6

> **Sprint type**: Cleanup / DevOps
> **Estimated effort**: 0.5 nap

---

## 🎯 Cél (Goal)

Eltávolítani a régi, nem használt Login / Register A/B képernyőket és kódrészeket, felülvizsgálni a lokalizációs kulcsokat, valamint megerősíteni a GitHub Actions CI pipeline‑t.

---

## 📂 Érintett/új fájlok

| Fájl                                         | Művelet    | Leírás                                                                  |
| -------------------------------------------- | ---------- | ----------------------------------------------------------------------- |
| `lib/screens/login_register_screen.dart`     | **DELETE** | Régi monolit A/B képernyő                                               |
| `lib/screens/login_screen_variant_b.dart`    | **DELETE** | Experiment variáns                                                      |
| `lib/experiments/remote_config_service.dart` | **DELETE** | Kísérleti RC service                                                    |
| `lib/l10n/`                                  | **PRUNE**  | Nem használt kulcsok eltávolítása (.arb)                                |
| `.github/workflows/flutter_ci.yaml`          | **UPDATE** | `flutter drive` guest & login flow hozzáadása                           |
| `README.md`                                  | **UPDATE** | Friss screenshot a modern Login képernyőről (PNG link a docs/images‑be) |

> **Megjegyzés**  Bináris screenshotot manuálisan kell a `docs/images` alá felvenni; Codex csak a README linket frissíti.

---

## ✅ Feladatlista

1. **Legacy file deletion** – távolítsd el a +obsolete fájlokat a repo-ból.
2. **L10n prune** – futtasd a `l10n_unused_key_checker.dart` scriptet, majd töröld a holt kulcsokat.
3. **CI update** – GitHub Actions: add step `flutter drive --target=integration_test/guest_routeguard_test.dart`.
4. **README.png link** – cseréld a régi screenshot URL-t `docs/images/login_revamp_screenshot_v1.png`‑re.
5. **Widget‑ & e2e‑tests** – futtass minden teszt; snapshot frissítés, ha szükséges.

---

## 📋 Definition of Done

* Minden legacy fájl véglegesen törölve a főágon.
* `.arb` fájlok csak használt kulcsokat tartalmaznak; `flutter gen-l10n` zöld.
* GitHub Actions pipeline fut `flutter analyze`, `flutter test --coverage`, `flutter drive` vendég‑ & login‑flow-ra.
* README frissített screenshotot linkel.
* CI zöld; linter 0 hiba.

---

## 🚧 Korlátozások & Guard-rails

* Bináris fájl commitot Codex nem készít; screenshot URL‑t frissít csak.
* `pubspec.yaml` nem változik.
* Snapshot frissítés csak `--update-goldens` flaggel.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - delete: [
      lib/screens/login_register_screen.dart,
      lib/screens/login_screen_variant_b.dart,
      lib/experiments/remote_config_service.dart
    ]
  - modify: [
      lib/l10n/*.arb,
      .github/workflows/flutter_ci.yaml,
      README.md
    ]
```

---

*Ez a vászon a Sprint 6 (Legacy cleanup & CI) specifikációját rögzíti.*
