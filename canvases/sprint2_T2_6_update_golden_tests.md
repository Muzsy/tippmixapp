🎯 Funkció
A T2.6 feladata a színséma refaktor utáni golden tesztek (snapshot képernyőtesztek) újrafelvétele. Ezek a tesztek biztosítják, hogy minden képernyő, minden skin, világos és sötét módban is helyesen, vizuális regresszió nélkül renderelődik az új Theme/ThemeExtension alapú rendszerrel. A régi (színrefaktor előtti) PNG-ket frissíteni kell, minden nézetet újra kell rögzíteni, majd elkötelezni a repo-ba.

🧠 Fejlesztési részletek
Futtasd a golden tesztek frissítését:

bash
Másolás
Szerkesztés
flutter test --update-goldens
Ellenőrizd, hogy minden érintett képernyőhöz és skin-hez létrejön a megfelelő PNG fájl (pl. /test/goldens/ alatt).

Modulonként/feature-önként külön commit, hogy könnyebb legyen review-zni.

Ellenőrizd, hogy minden új PNG diff-je megfelel az elvártnak (vizuális regresszió nincs).

Ha egy golden teszt snapshot eltér a várttól, vagy design hiba van, javítsd a widgetet vagy Theme-t, majd frissítsd a goldent.

Friss PNG-ket commitold a repo-ba.

CI pipeline-ban legyen golden diff, hogy minden PR-ban ellenőrzött legyen a vizuális egyezés.

Figyelem: ha nagy a skin- és képernyőszám, optimalizáld PNG méretre (png-8, stb.).

🧪 Tesztállapot
Minden golden teszt frissítve, elfogadva.

CI pipeline zöld, golden diff pass minden skin × brightness kombinációban.

Nincs vizuális regresszió.

🌍 Lokalizáció
Nem érint, de a golden képek lokalizációs állapotát is érdemes ellenőrizni.

📎 Kapcsolódások
Előzmény: T2.5 linter warningmentes kód.

„Figyelem! A golden teszt PNG fájlokat csak manuálisan, fejlesztői gépen lehet generálni és commitolni. Codex workflow ezt NEM tudja elvégezni, csak a szöveges kódmódosításokat és a teszt szkriptek futtatását. A PNG fájlokat git add, git commit, git push parancsokkal kell a repóba rakni.”

Következő: T2.7 (accessibility audit), T2.8 (összegző canvas + yaml).

Minden fejlesztőnek, QA-nak stabil vizuális baseline.

