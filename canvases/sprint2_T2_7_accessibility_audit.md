🎯 Funkció
A T2.7 célja az új színséma rendszer hozzáférhetőségi (a11y) auditjának elvégzése. Ellenőrizni kell, hogy a Theme/ThemeExtension alapú színhasználat minden skin, minden képernyő, minden mód (light/dark) esetén megfelel a WCAG AA kontrasztkövetelményeknek, valamint a főbb accessibility toolok sem jeleznek hibát (screen reader, keyboard nav, kontraszt analízis). Ez a minőségi garancia, hogy az alkalmazás minden felhasználónak elérhető, olvasható és akadálymentes lesz.

🧠 Fejlesztési részletek
Futtasd a hozzáférhetőségi audit eszközt:

Használd a flutter_a11y vagy más megfelelő accessibility audit toolt.

Parancs:

bash
Másolás
Szerkesztés
flutter pub run flutter_a11y:check
Ez ellenőrzi a kontrasztot, hierarchiát, alternatív szövegeket, stb.

Ellenőrizd a generált riportot (a11y_report.html vagy más formátum).

Kritikus: WCAG AA kontraszt:

Normál szöveg ≥ 4.5:1

Nagy szöveg ≥ 3:1

Minden warning/hiba:

Azonnal javítani a színsémát vagy widgetet.

A riportot (HTML, CSV stb.) archíváld a /tools/reports/ mappába.

CI pipeline-ba is érdemes beépíteni, hogy minden PR-nál automatikusan fusson.

Manuális ellenőrzés 1-2 eszközön (iOS, Android, dark/light mód), screen reader, nagyítás, szín invertálás stb.

🧪 Tesztállapot
a11y_report.html warning/hiba = 0, minden minimum elvárás teljesül.

CI pipeline zöld, accessibility audit warningmentes.

Manuális tesztelés során is minden fő funkció akadálymentes.

🌍 Lokalizáció
Alternatív szövegek, label-ek lokalizációja kötelező.

Az audit ezt is ellenőrzi!

📎 Kapcsolódások
Előzmény: T2.6 (frissített golden baseline).

„Fontos: a Codex nem módosíthatja a pubspec.yaml-t, azt mindig manuálisan kell szerkeszteni! Az accessibility_tools csomagot manuálisan kell felvenni a dev_dependencies-hez, ezt követően a Codex folytathatja az accessibility audit integrációját a kódban.”

Következő: T2.8 (összegző canvas + yaml, végső zárás).

Szükséges minden bővítés, új skin, UI módosítás esetén is.