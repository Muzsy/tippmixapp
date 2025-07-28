# Sprint9 – reCAPTCHA blokkolás feloldása (Debug‑bypass + valódi token kezelése)

## Kontextus

A regisztráció első lépésén (Step 1) a reCAPTCHA‑ellenőrzés mindig hibát dob, mert

* a frontenden *hard‑code* "token" szöveget küld a Google `siteverify`‑nek, és
* a `RecaptchaService` "test-secret" kulccsal hívja az API‑t.
  Így a flow meg sem kezdi a lapozást → `registerWithEmail()` nem fut.

## Cél

* **Fejlesztői / teszt környezetben** egyszerű bypass, hogy a folyamat végigfuthasson.
* **Éles környezetben** a valódi token kerüljön elküldésre a backendnek vagy a Google API‑nak.

## Feladatok

* [ ] **RecaptchaService**

  * Ha `kDebugMode`, térjen vissza `true` (bypass).
  * Production‑ág változatlanul hívja a Google `siteverify`‑t.
* [ ] **RegisterStep1Form**

  * `token = await recaptcha.execute()` – ne "token" literál.
  * Hibakezelés: ha `verifyToken()` hamis, SnackBar és `return`.
* [ ] **Teszt**

  * *Widget* `recaptcha_bypass_allows_step2` – debug módban kitölti Step 1 mezőket, gomb után Step 2 jelenik meg.
  * *Integration* `register_flow_debug_no_recaptcha_test.dart` – teljes happy path Firebase Emulatorral.
* [ ] CI: `flutter analyze` + tesztek zöld.

## Acceptance Criteria

* [ ] Debug buildben a wizard mindig Step 2‑re lapoz.
* [ ] Release buildben a reCAPTCHA token **nem** "token", hanem valódi érték.
* [ ] Szenzitív kulcs `.env`‑ből / `RemoteConfig`‑ből, nem hard‑code.
* [ ] Minden teszt zöld, `flutter analyze` hibamentes.

## Hivatkozások

Canvas → `/codex/goals/sprint9_recaptcha_fix.yaml`
Érintett fájlok: `lib/services/recaptcha_service.dart`, `lib/ui/auth/register_step1_form.dart`
