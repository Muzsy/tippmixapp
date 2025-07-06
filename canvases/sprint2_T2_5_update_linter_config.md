🎯 Funkció
A T2.5 célja, hogy a projekt linter (elemző) beállításait kiegészítsük a színséma refaktorhoz szükséges szabályokkal. Legfontosabb, hogy a hardcoded színek (pl. Colors.*, hex, rgb) előfordulását a linter azonnal jelezze, hibaként (warning vagy error) kezelje, így többé semmilyen manuális színezés nem kerülhet a kódba. A linter futtatása minden commitnál, CI pipeline-ban kötelező. A szabály bevezetése után minden kód warningmentes kell legyen.

🧠 Fejlesztési részletek
analysis_options.yaml fájlban bővíteni kell a szabályokat:

avoid-hard-coded-colors

(opcionális, ha van: prefer-theme-colors, a11y_contrast)

A linter beállítása warning/error-ra, így blokkol minden manuális színt (Colors.*, hex, rgb, stb.).

CI pipeline-ban is kötelezően fusson, a warningokat blokkolja (fail-on-warning).

Kézi teszt: szúrj be egy hibás Colors.red sort – warning/error legyen.

Ellenőrzés: minden kódbázisban maradt warning/hardcoded szín javítva van.

A szabály bevezetését dokumentáld a fejlesztői readme-ben, ha szükséges.

🧪 Tesztállapot
flutter analyze és CI pipeline warning = 0.

Hardcoded szín beillesztésekor a linter azonnal jelez.

PR/commit blokkolódik, ha manuális szín marad a kódban.

🌍 Lokalizáció
Nem érinti.

📎 Kapcsolódások
Előzmény: T2.4 teljes refaktor, minden színhasználat theme-ből történik.

Következő: T2.6 (golden test frissítés), T2.7 (accessibility audit), T2.8 (canvas+yaml összegzés).

Hosszútávon: minden új fejlesztő vagy feature már automatikusan megfelel a színséma szabályoknak.