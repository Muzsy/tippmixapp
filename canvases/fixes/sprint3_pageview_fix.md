# Sprint3 – PageView navigáció javítása (Step 1 → Step 2)

## Kontextus

A regisztráció első képernyőjéről (E‑mail + jelszó) a **Tovább** gomb megnyomása után a wizardnak a második oldalra kellene lapoznia. Jelenleg az animáció néha kivételt dob (`Looking up a deactivated widget`), ami lenyeli a hibát, így a felhasználó megakad, a flow nem folytatódik.

## Cél

Garantálni, hogy a Step 1 valid kitöltése után a PageView **mindig** sikeresen Step 2‑re váltson, valamint hogy az esetleges kivételek felhasználó‑barát hibaüzenetben jelenjenek meg.

## Feladatok

* [ ] `register_step1_form.dart` – adjunk `if (!mounted) return;` guardot az `await animateToPage()` elé.
* [ ] Csomagoljuk `animateToPage()` hívást `try/catch`‑be, `catch`‑ágban `showSnackBarError()` mutasson hibaüzenetet.
* [ ] Widget‑teszt: „step1\_to\_step2\_navigation” – kitölti a mezőket, megnyomja **Tovább**, majd assertálja, hogy megjelenik a Step 2‑höz tartozó `nickname` mező.
* [ ] `flutter analyze`, `flutter test` – mindkettő zöld.

## Acceptance Criteria

* [ ] A felhasználó minden sikeres első lépés után Step 2‑re jut.
* [ ] Hiba esetén SnackBar jelenik meg „Ismeretlen hiba, próbáld újra” szöveggel.
* [ ] Nincs analyze‑figyelmeztetés, minden teszt zöld.

## Hivatkozás

* Canvas → `/codex/goals/sprint3_pageview_fix.yaml`
* Sablon: Codex Canvas Yaml Guide
