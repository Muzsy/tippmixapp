# 🔐 Bejelentkezés képernyő (LoginScreen)

Ez a vászon a TippmixApp bejelentkező képernyőjének újravizsgált, WCAG‑AA kompatibilis megvalósítását írja le.  A cél egy fókuszált és akadálymentes `LoginScreen`, amely e‑mail/jelszó és több social‑login opciót kínál, és sikeres hitelesítés után a főképernyőre vagy a regisztrációs varázslóra navigál【522359040739838†L7-L10】.

## 🎯 Cél

- **E‑mail/jelszó és social login** – támogatja a Google, Apple és Facebook bejelentkezést【522359040739838†L7-L10】.
- **Navigáció** – sikeres bejelentkezés után a Home képernyőre (`HomeLogged`), sikertelen esetben hibakezelés; a regisztrációs varázslóra mutató link a képernyő alján【522359040739838†L27-L33】.
- **Teljes lokalizáció** – a képernyő három nyelven (hu/en/de) jelenik meg, a szövegek minden esetben lokalizált kulcsokra épülnek【522359040739838†L9-L10】【522359040739838†L43-L47】.
- **CI és tesztek** – a megvalósítást linter‑ és tesztkötések kísérik (`flutter analyze`, `flutter test --coverage`)【522359040739838†L20-L22】.

## 🧠 Felépítés

- **login_screen.dart** – scaffold, logó és cta‑k; a social login gombok különálló rectangular button widgetek【522359040739838†L15-L20】.
- **login_form.dart** – email és jelszó mezők, jelszó láthatóság toggle【522359040739838†L15-L19】.
- **AuthService refactor** – típusos metódusok (`signInWithEmail`, `signInWithGoogle`, stb.), amelyek `Either<Failure, User>` eredménnyel térnek vissza【522359040739838†L19-L20】.
- **Vendég‑flow** – ha a felhasználó már be van jelentkezve (`uid != null`), automatikusan a HomeLogged képernyőre jut【522359040739838†L33-L35】.
- **Unit- és widget‑tesztek** – sikeres és sikertelen login útvonalak, három nyelv screenshot‑golden; CI guard biztosítja a 80 % feletti test‑coverage‑et【522359040739838†L20-L36】.

## 📄 Kapcsolódó YAML fájlok

- `codex/goals/fill_canvas_login_screen.yaml` – a bejelentkezés képernyő Codex utasításfájlja.
- `codex/goals/fix_login_logic.yaml`, `codex/goals/fix_login_logic_v2.yaml` – hibajavítások a login folyamatban.
- `codex/goals/fill_canvas_forgot_password.yaml` – elfelejtett jelszó képernyő (külön vászon).

## 🧪 Tesztállapot

Az implementáció 100 %‑ban teszteltnek van tervezve.  A widget és unit tesztek ellenőrzik a helyes navigációt, a hibakezelést, a social login funkciókat és a lokalizációt【522359040739838†L27-L36】.

## 📎 Modul hivatkozások

- `auth_service.md` – az autentikációs logika.
- `auth_provider.md` – a bejelentkezett felhasználó kezelésére.
- `router.dart` – a bejelentkezés utáni navigáció.
- `register_wizard` képernyők – regisztrációs flow (folyamatban).
