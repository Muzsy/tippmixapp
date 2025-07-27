# Email+jelszavas regisztráció – Teljes flow tesztelése és javítása

## Kontextus

A `registerWithEmail()` metódus jelenleg nem hívódik meg a regisztrációs folyamat végén. A debugger, print és teszt sem igazolja, hogy a hívás megtörténne. Ezen kívül az egész regisztrációs folyamat nem teljesen letesztelt: a multi-step űrlapok, az AppCheck, az email-verifikáció, a backend-hívások és az átirányítás sincs garantáltan működőképes állapotban.

## Cél

A teljes regisztrációs folyamat hibátlan működésének biztosítása, több fájl együttműködésével. A Codex biztosítsa, hogy az `AuthService.registerWithEmail()` metódus meghívódik, és a teljes folyamat végigfut, valid input esetén. Írjunk teljeskörű integration tesztet, ami ezt automatikusan ellenőrzi.

## Feladatok

- [ ] Azonosítani, honnan (melyik UI vagy állapotkezelőből) kellene meghívódnia a `registerWithEmail()`-nek.
- [ ] Ha hiányzik a hívás, építsük be a `RegisterNotifier`, `RegisterWizard`, vagy `Step3Form` logikába.
- [ ] Győződjünk meg róla, hogy minden async várakozás (`await`) megtörténik, és nem vesznek el kivételek.
- [ ] Illesszük be `print('[REGISTER] STARTED')` és `print('[REGISTER] SUCCESS')` logokat a metódusba.
- [ ] Hozzunk létre egy `integration_test/register_flow_test.dart` fájlt, amely végigmegy a teljes regisztráción.
- [ ] A teszt során ellenőrizzük, hogy minden képernyő megjelent, az emailVerif logika meghívódott, és a hívások sorrendje helyes.
- [ ] Az AppCheck token is legyen lekérdezve (`getToken()`).
- [ ] Hiba esetén megfelelő SnackBar jelenjen meg.

## Acceptance Criteria / Done Definition

- [ ] A regisztrációs flow során meghívódik az `AuthService.registerWithEmail()` metódus
- [ ] A tesztlogban megjelenik `[REGISTER] STARTED` és `[REGISTER] SUCCESS`
- [ ] A teszt szerint a felhasználó regisztrálódik és az email-verifikációs képernyő megjelenik
- [ ] A `integration_test/register_flow_test.dart` minden lépést ellenőriz
- [ ] `flutter test`, `flutter drive` és `flutter analyze` sikeres
- [ ] Hibaágak is leteszteltek (pl. foglalt email, gyenge jelszó)

## Hivatkozások

- Canvas → `/codex/goals/fill_canvas_register_flow_full_test.yaml`
- Érintett fájlok: `register_step1_form.dart`, `register_wizard.dart`, `register_state_notifier.dart`, `auth_service.dart`, `integration_test/register_flow_test.dart`
