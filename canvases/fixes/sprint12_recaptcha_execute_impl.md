# Sprint 12 – reCAPTCHA token lekérése és integrálása

## Kontextus

A `RecaptchaService.execute()` metódus jelenleg csak *debug* módban ad vissza értelmes (`"debug-token"`) stringet, **release** buildben pedig üres stringet (`""`). Emiatt a későbbi `verifyToken()` hívás a Google `siteverify`‑t üres paraméterrel éri el, a válasz *false* lesz, és a regisztrációs folyamat Step 1‑en elakad.

* Érintett fájl: `lib/services/recaptcha_service.dart`
* Érintett UI: `lib/screens/register_step1_form.dart`

## Cél

* **Debug / teszt build**‑ben változatlanul térjen vissza instant *bypass* (`"debug-token"`).
* **Weben** láthatatlan (invisible) reCAPTCHA‑val kérjünk tokent a Firebase Auth SDK `RecaptchaVerifier` osztályával.
* **Mobilon** (Android / iOS) használjuk a Firebase App Check tokent fallbackként.
* Időtúllépés (10 s) vagy sikertelen token kérés esetén dobjunk kivételt → SnackBar‑rel jelezze az UI.

## Feladatok

1. **RecaptchaService.execute()** teljes implementálása

   * `kDebugMode` ágat megtartjuk.
   * `kIsWeb` esetén `RecaptchaVerifier` → `verifier.render()` + `verifier.verify()` → `Completer<String>`.
   * Egyéb platformokon `FirebaseAppCheck.instance.getToken()` → `token`.
   * Ha a token üres vagy `null`, `throw Exception('Unable to acquire reCAPTCHA token')`.
2. **Importok frissítése**
   `package:firebase_auth/firebase_auth.dart` `as fb`,
   `package:firebase_app_check/firebase_app_check.dart`,
   `package:flutter/foundation.dart` → `kIsWeb`.
3. **UI hibakezelés** – `register_step1_form.dart`‑ban kapjuk el a kivételt, és jelenítsük meg SnackBar‑ben.
4. **Teszt**

   * *Widget* `recaptcha_web_token_returns_non_empty` → mock `kIsWeb=true`, `RecaptchaVerifier` stub  ⇒ nem üres token.
   * *Integration* Emulátorban mobil build (`--debug`) – debug‑bypass miatt Step 2‑re lapoz.
5. **CI** – `flutter analyze` + `flutter test` zöld.

## Acceptance Criteria

* Release buildben **nem** üres tokennel hívjuk a Google API‑t.
* Step 1 SnackBar csak valós hibánál jelenik meg (pl. token timeout).
* `[REGISTER]` logok megjelennek, és a wizard tovább lapoz Step 2‑re.

## Hivatkozások

Canvas → `/codex/goals/sprint12_recaptcha_execute_impl.yaml`
Érintett fájlok: `lib/services/recaptcha_service.dart`, `lib/screens/register_step1_form.dart`
