# Regisztráció – `registerWithEmail` hívás bekötése & teljes flow-teszt

## Kontextus  
A több-lépcsős regisztráció végén **nem hívódik meg** az `AuthService.registerWithEmail()` metódus, ezért sem Firebase-oldali fiók-létrehozás, sem App Check token, sem e-mail-megerősítés nem indul el. A Codex-es sprintfeladatok ugyan létrehozták a szükséges helper-fájlokat és teszteket, de a tényleges hívási lánc (UI → StateNotifier → AuthService) hiányos.  

## Cél  
Bekötni a hiányzó metódushívást, valamint létrehozni egy **end-to-end integration tesztet**, amely végigviszi az egész regisztrációs folyamatot, és bizonyítja a hibátlan működést.

## Feladatok  
- [ ] Keressük meg a végső regisztráció-indító pontot (várhatóan `RegisterStateNotifier.completeRegistration()` vagy `RegisterWizard.onFinish()`), és illesszük be az `await AuthService().registerWithEmail(...)` hívást.  
- [ ] Adjunk debug-logot:  
  `print('[REGISTER] STARTED');` → hívás elején,  
  `print('[REGISTER] SUCCESS');` → sikerág végén.  
- [ ] Hibakezelés: dobott kivételekre SnackBar a már meglévő `error_mapper.dart`-tel.  
- [ ] Sikeres hívás után:  
  - küldjünk `sendEmailVerification()`-t (ha még nem aktív),  
  - navigáljunk az `EmailNotVerifiedScreen`-re (AuthGate már védi a többi route-ot).  
- [ ] **Widget-teszt** – mockolt AuthService-zel ellenőrizzük, hogy a gomb megnyomása meghívja a metódust és a logot.  
- [ ] **Integration-teszt** (`integration_test/register_flow_test.dart`) – Firebase Emulatorral végigmegy az űrlapokon, létrehozza a felhasználót, és a végén megjelenik az `EmailNotVerifiedScreen`.  
- [ ] `flutter analyze` és minden teszt zöld.

## Acceptance Criteria / Done Definition  
- [ ] A debug-logban látszik `[REGISTER] STARTED` és `[REGISTER] SUCCESS`.  
- [ ] A felhasználó objektum ténylegesen létrejön a Firebase Emulatorban.  
- [ ] Az integration teszt végén az `EmailNotVerifiedScreen` látható.  
- [ ] `flutter test`, `flutter drive` és `flutter analyze` hibamentes.  

## Hivatkozások  
Canvas → `/codex/goals/fill_canvas_register_flow_register_call.yaml`  
Kapcsolódó fájlok: `register_state_notifier.dart`, `register_wizard.dart`, `auth_service.dart`, `integration_test/register_flow_test.dart`
