🎯 Funkció
A T2.2 feladat célja, hogy a T2.1-ben elkészült codemod_replace_hex.dart scriptet dry-run módban futtassuk le az egész kódbázison, és a találatokat naplófájlba exportáljuk. Ez biztosítja, hogy minden hard-coded hex-szín feltérképezésre kerül, és a későbbi automatikus cserék előtt manuálisan is áttekinthető, mely sorokat érint a refaktor.

🧠 Fejlesztési részletek
Script futtatása:

Parancs:

sh
Másolás
Szerkesztés
dart run tools/codemods/codemod_replace_hex.dart --dry-run
A script csak listáz, nem módosít.

Az eredményeket egy jól áttekinthető log fájlba (pl. codemod_dryrun.log) menti, amely tartalmazza a módosítandó fájlokat, sorszámokat, talált hex-színeket, és a javasolt Theme-referenciákat is.

Review log:

A fejlesztő(k) manuálisan átnézik a logot, ellenőrzik a találatokat (különös tekintettel a helytelen mapping vagy komplex widgetek kiszűrésére).

Hibás vagy nem automatikusan cserélhető eseteket kiemeljük a logban, ezek manuális beavatkozást igényelnek majd (T2.4).

Elfogadási kritériumok:

A log minden várható cserét tartalmaz, egyértelműen visszakereshető a forráskódban.

Nincsenek üres vagy félbemaradt logok.

A script nem módosít semmit a kódban ebben a lépésben.

🧪 Tesztállapot
A dry-run log áttekintése után egyeznie kell a Sprint0 audit során talált hard-coded színek számával (ellenőrző lépés).

Manuális ellenőrzés, hogy minden szükséges hely szerepel-e.

🌍 Lokalizáció
A log fejlesztői célú, nincs lokalizációs kitettsége, angol/magyar nyelvű kommentek szükség szerint.

📎 Kapcsolódások
Közvetlen előzménye: T2.1 (codemod script).

Közvetlen következménye: T2.3 (apply codemod), T2.4 (manuális korrekciók).

Hivatkozik a Sprint0 szín-audit riportjára az összehasonlítás miatt.