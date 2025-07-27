# Debug – registerWithEmail nem hívódik meg

## Kontextus

A `registerWithEmail()` metódus nem kerül meghívásra az email+jelszavas regisztráció során. A debug breakpoint nem aktiválódik, a `print()` sem fut le. Ez arra utal, hogy UI oldalról nem jut el a logika eddig a pontig.

Korábban az App Check token validálás már be lett építve, de mivel a metódus maga nem hívódik meg, a hiba ettől független lehet. Gyanítható, hogy a regisztrációs flow valamelyik lépése hibásan vagy egyáltalán nem hívja meg a végső regisztrációs logikát.

## Cél

Azonosítani, hogy a `registerWithEmail()` miért nem fut le, majd a hibát automatikusan javítani.

## Feladatok

- [ ] Végigkövetni a teljes regisztrációs folyamatot (pl. `RegisterWizard`, `RegisterNotifier`, `PageController`, `Step1Form` stb.).
- [ ] Feltérképezni, milyen esemény vagy UI akció hívná meg a `registerWithEmail`-t.
- [ ] Ellenőrizni, hogy ez a hívás ténylegesen megtörténik-e (`onPressed`, `onTap`, `Notifier`, `Wizard` stb.).
- [ ] Ha nem, kijavítani a hívási láncot.
- [ ] Tesztelni, hogy a metódus ténylegesen lefut és a debug log is megjelenik.
- [ ] Automatikus tesztet írni, amely ezt validálja.
- [ ] Integrációs teszt, ami a teljes regisztrációs flow-t végigviszi.

## Acceptance Criteria / Done Definition

- [ ] `registerWithEmail()` meghívódik `print()` loggal tesztelve
- [ ] A kapcsolódó tesztben megjelenik a `[REGISTER]` log
- [ ] A felhasználó ténylegesen regisztrálódik a tesztben
- [ ] Legalább egy widget- és egy integrációs teszt lefedi a regisztrációt
- [ ] `flutter test` és `flutter analyze` hibamentesen lefut

## Hivatkozások

- Canvas → `/codex/goals/fill_canvas_debug_register_method_not_called.yaml`
- Fájlok: `auth_service.dart`, `register_state_notifier.dart`, `register_wizard.dart`, `register_step1_form.dart`, `main.dart`, `app_check_debug.dart`
