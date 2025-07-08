# RegisterWizard – Step 3 (Avatar Upload) Implementation – Sprint 4 *(Final)*

> **Sprint type**: Feature implementation
> **Estimated effort**: 1.5 nap

---

## 🎯 Cél (Goal)

Megvalósítani a Regisztrációs varázsló **Step 3 – Avatar Upload** képernyőjét, ahol a felhasználó **fényképet készíthet a kamerával vagy választhat egy meglévő képfájlt** avatarként. A kép előnézetben ellenőrizhető, majd az alkalmazás feltölti. A lépés végén befejeződik a teljes regisztráció, és a felhasználó a főképernyőre navigál.

---

## 📂 Érintett/új fájlok

| Fájl                                         | Típus    | Leírás                                                       |
| -------------------------------------------- | -------- | ------------------------------------------------------------ |
| `lib/screens/register_step3_form.dart`       | Widget   | Avatar picker (kamera / fájl), preview, Skip / Finish gombok |
| `lib/services/storage_service.dart`          | Service  | **Új**: `uploadAvatar(File)` (Firebase Storage wrapper)      |
| `lib/providers/register_state_notifier.dart` | Riverpod | Állapot frissítés, `completeRegistration()`                  |
| `test/widgets/register_step3_form_test.dart` | Test     | Widget-tesztek kamera/fájl pick + skip flow                  |
| `.github/workflows/flutter_ci.yaml`          | CI       | Workflow-bővítés az új tesztekhez                            |

---

## 📑 Mező-specifikáció *(Sprint 0-ból)*

```json
[
  { "step": 3, "field": "avatar", "label": "Avatar image", "type": "image", "validation": "optional, ≤2 MB, square" }
]
```

---

## ✅ Feladatlista

1. **Step 3 widget** – `RegisterStep3Form` kamera‑ és fájl‑alapú avatar pick UI‑val, előnézettel, `Skip` és `Finish` CTA‑kkal.
2. **Image selection, capture & crop** – `ImagePickerService` integrálása `ImageSource.camera` és `ImageSource.gallery` támogatással; 1:1 vágás, ≤2 MB.
3. **Storage feltöltés** – `uploadAvatar()` Firebase Storage‑ba; URL mentése `registerStateNotifier`‑ben.
4. **Skip flow** – Skip gomb esetén képfeltöltés nélkül folytatódjon a regisztráció.
5. **Végleges regisztráció** – `registerStateNotifier.completeRegistration()`, majd `context.goNamed(AppRoute.home)`.
6. **Widget‑ & unit‑tesztek** – kamera‑fotó, fájl pick, nagy fájl hibakezelés, skip flow, happy path.
7. **CI guard** – coverage ≥ 80 %, `flutter analyze` 0 hiba.

---

## 📋 Definition of Done

* Step 3 HU/EN/DE lokalizációval működik.
* Avatar ≤2 MB, négyzetes, URL mentve a Firestore `users.avatarUrl` mezőbe.
* Kamera‑ és fájl‑alapú képválasztás egyaránt működik.
* Skip flow is működik.
* CI zöld (tesztek, lint).

---

## 🚧 Korlátozások & Guard‑rails

* **pubspec.yaml nem módosítható** – csak meglévő image‑picker / storage dependenciák használhatók.
* Bináris asset commit tilos.
* Stringek `.arb`‑ba.
* Firebase Storage path: `avatars/{uid}.jpg`.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - lib/screens/register_step3_form.dart
  - lib/services/storage_service.dart
  - lib/providers/register_state_notifier.dart
  - test/widgets/register_step3_form_test.dart
  - .github/workflows/flutter_ci.yaml
  - l10n/.arb (kulcs-update)
```

---

*Ez a vászon a végleges Sprint 4 követelményeket tartalmazza, kamera‑ és fájl‑alapú avatar feltöltéssel.*
