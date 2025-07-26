# 👤 Profil képernyő (ProfileScreen)

Ez a vászon a felhasználói profil felületét írja le, ahol a TippmixApp játékosai megtekinthetik és szabályozhatják személyes adataik megjelenését.  A profiloldal célja, hogy átláthatóvá tegye a statisztikákat (TippCoin, szint, badge‑ek, nyerési arány, streak), és egyéni publikusság beállítási lehetőségeket nyújtson【977227879272921†L6-L8】.

## 🎯 Funkció

* A profiloldal megjeleníti az **avatar** és **nickname** mezőket (mindig publikus), valamint opcionális adatokat, mint város, ország, kedvenc sport és csapat【977227879272921†L6-L7】.
* Minden mezőhöz publikus/privát kapcsoló tartozik, kivéve az avatar és a nickname mezőket【977227879272921†L19-L27】.
* Globális privát mód állítható be, amely esetén csak az avatar és nickname látható mások számára【977227879272921†L23-L25】.

## 🧠 Felépítés

A profilképernyő modulokra tagolódik:

- **ProfileHeader** – avatar, nickname, TippCoin, szint és streak.
- **VisibilityToggles** – publikus/privát kapcsolók minden mezőn【977227879272921†L19-L27】.
- **GlobalPrivacySwitch** – egyetlen váltó, amely minden mezőt privát módba állít【977227879272921†L23-L25】.
- **BadgeGrid** – a megszerzett badge‑ek listája; külön badge képernyőre navigálás lehetőségét is kínálja.
- **Actions** – nickname módosítása, avatar feltöltése, profil szerkesztése (későbbi fázis).

A Firestore modell kiegészítő mezőkkel rendelkezik (`isPrivate`, `fieldVisibility`), amelyeket a felület módosíthat【977227879272921†L23-L25】.

## 📄 Kapcsolódó YAML fájlok

- `codex/goals/fill_canvas_profile_screen.yaml` – a profil képernyő generálásához készült Codex utasítás.
- `codex/goals/fill_canvas_profile_finish_wizard_multilang.yaml` – a profil befejező varázsló multi‑language kiterjesztése.
- Javítások: `codex/goals/fix_home_screen_showstats.yaml` érinti a stats megjelenítését.

## 🐞 Fixek és tanulságok

A profil képernyő korábbi iterációiban több hibajavítás történt, például a nickname egyediség-ellenőrzés és a publikus/privát toggle hibáinak javítása.  Ezeket a vásznakat archiváltuk a `canvases/_archive/fixes/` könyvtárba (pl. `profile_screen_test.md`, `profile_screen_localization_and_tests.md`).  A tanulság, hogy a publikus/privát beállítások logikáját egységesen, modellvezérelten kell kezelni.

## 🧪 Tesztállapot

A profiloldalhoz unit- és widget‑tesztek tartoznak【977227879272921†L31-L37】:

- **Alapprofil megjelenítés** – avatar, nickname, fő statok és badge‑ek helyes renderelése.
- **Publikus/privát kapcsolók tesztje** – minden mezőhöz külön tesztek.
- **Globális privát mód teszt** – ellenőrzi, hogy csak az avatar és nickname látszik.
- **Nickname egyediség** – teszt a megfelelő hibaüzenet megjelenítésére.

## 📎 Modul hivatkozások

- `badge_grid_widget` (module) – lásd `modules/profile_badge_widget.md`.
- `badge_service.md` és `badge_model.md` – a kitüntetések logikája és adatmodellje.
- `stats_service.md` – a felhasználói statisztikák szolgáltatója.
- `auth_provider.md` – a bejelentkezett felhasználó adatai.