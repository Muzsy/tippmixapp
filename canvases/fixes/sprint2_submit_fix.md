# Sprint2 – Regisztráció befejező hívás javítása

## Kontextus

A háromlépcsős regisztráció végén (Wizard Step 3) a `RegisterStateNotifier.completeRegistration()` nem várja meg aszinkron módon az `AuthService.registerWithEmail()` hívást, sőt a metódus a legtöbb buildben meg sem hívódik. Emiatt App Check, Firebase‑Auth és e‑mail‑verifikáció sem fut le fileciteturn2file12.

## Cél

Biztosítani, hogy a *Befejezés* gomb megnyomására **mindig** lefusson a `registerWithEmail()` hívás, `await`‑elve, és hibamentesen végigérjen a flow.

## Feladatok

- [ ] Tegyük `async`‑ká a `RegisterStateNotifier.completeRegistration()` metódust és `await`‑eljük az `auth.registerWithEmail()`‑t.
- [ ] A `RegisterWizard` Step 3 *Befejezés* gombjának `onPressed` callbackje legyen `async` és `await`‑elje a notifier metódust.
- [ ] Adjuk hozzá a debug‑logot: `print('[REGISTER] STARTED')` és `print('[REGISTER] SUCCESS')`.
- [ ] Írjunk unit‑tesztet (mockolt `AuthService`) ami ellenőrzi, hogy `completeRegistration()` **await**‑eli a hívást.
- [ ] Futtassuk a `flutter analyze` és `flutter test` parancsokat.

## Acceptance Criteria / Done Definition

- [ ] `[REGISTER] STARTED/SUCCESS` log megjelenik valid regisztrációnál
- [ ] `flutter analyze` hibamentes
- [ ] Minden teszt zöld
- [ ] Teszt‑lefedettség ≥ 80 %

## Hivatkozások

- Canvas → `/codex/goals/sprint2_submit_fix.yaml`
- Kapcsolódó beszélgetés: Firebase App Check probléma fileciteturn2file12
- Sablon: Codex Canvas Yaml Guide fileciteturn2file2
