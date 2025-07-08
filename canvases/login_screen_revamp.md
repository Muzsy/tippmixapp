# LoginScreen Implementation – Sprint 1

> **Sprint type**: Feature implementation
> **Estimated effort**: 1.5 nap

---

## 🎯 Cél (Goal)

Fókuszált, WCAG‑AA kompatibilis **LoginScreen** elkészítése, amely e‑mail/jelszó és három social‑login opciót (Google, Apple, Facebook) kínál, és hiba nélkül navigál a főképernyőre vagy a Regisztrációs varázslóra. A képernyő három nyelven (HU/EN/DE) lokalizált, 100 %‑ban tesztelt és linter‑tiszta.

---

## 📂 Érintett/új fájlok

| Fájl                                  | Típus       | Leírás                                                                                       |
| ------------------------------------- | ----------- | -------------------------------------------------------------------------------------------- |
| `lib/screens/login_screen.dart`       | Widget      | Átfogó képernyő, scaffold, logo, CTA‑k                                                       |
| `lib/screens/login_form.dart`         | Widget      | Űrlap: email, jelszó, szem ikon toggler                                                      |
| `lib/services/auth_service.dart`      | Service     | **Refactor**: `signInWithEmail`, `signInWithGoogle`, `signInWithApple`, `signInWithFacebook` |
| `test/widgets/login_screen_test.dart` | Widget‑test | Sikeres login → `HomeLogged`, sikertelen → hiba snackbar                                     |
| `.github/workflows/flutter_ci.yaml`   | CI          | `flutter analyze && flutter test --coverage` lépés bővítve                                   |

> **Megjegyzés**  Bináris (PNG, SVG) assetet a Codex **nem** generál; ikon/illustration placeholder `Icons.*`‑el.

---

## ✅ Feladatlista

1. **Widget skeleton** – `login_screen.dart` + komponensek; Material 3.
2. **Social‑login gombok** – különálló rectangular button widget mindhárom providerrel.
3. **Regisztráció link** – `router.goNamed(AppRoute.register)` alul.
4. **AuthService refactor** – új, típusos metódusok + `Either<AuthFailure, User>` visszatéréssel.
5. **Vendég‑flow** – ha `uid != null` → `HomeLogged`, különben marad.
6. **Widget‑ & unit‑tesztek** – happy + error path, 3 nyelv screenshot‑golden.
7. **CI guard** – linter, test‑coverage ≥ 80 %, `flutter analyze` 0 hiba.

*Task breakdown a `codex_goals_login_register_revamp_sprints.yaml` Sprint 1 szakasza alapján* fileciteturn4file0.

---

## 📋 Definition of Done

* Minden fenti feladat merge‑elve main ágra.
* `flutter analyze` & `flutter test --coverage` zöld a CI‑n.
* Képernyő HU/EN/DE lokalizációban működik.
* Accessibility: kontraszt > 4.5 : 1, `semanticsLabel` minden ikonon.
* Release‑note bejegyzés a CHANGELOG‑ban.

---

## 🚧 Korlátozások & Guard‑rails

* **Navigator.push** TILOS – csak `context.goNamed()` használható.
* Hard‑coded stringek helyett `loc(context).kulcs`.
* `pubspec.yaml` nem módosítható.
* Bináris fájl commit tilos.
* Folytassuk a projekt globális Codex‑szabályait (lásd `codex_readme.md`) fileciteturn5file7.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - lib/screens/login_screen.dart
  - lib/screens/login_form.dart
  - lib/services/auth_service.dart
  - test/widgets/login_screen_test.dart
  - .github/workflows/flutter_ci.yaml
  - l10n/.arb (kulcs‑update)
```

---

*Amint a canvas review‑elve és jóváhagyva, generálandó a `fill_canvas_login_screen.yaml` Codex‑utasításfájl, majd `codex run` Sprint 1 dry‑run.*
