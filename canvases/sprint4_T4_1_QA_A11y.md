Sprint4 T4.1 – Golden baseline script Codex-el (QA & Accessibility)
🎯 Funkció
A TippmixApp minden elérhető skin × világos/sötét mód × fő route kombinációjához automatizált golden baseline screenshot generálása Codex workflow-val, a Flutter szabványos golden-test API-jával. A cél, hogy a színséma architektúra CI-ban folyamatosan auditált, összehasonlítható és reprodukálható legyen.

🧠 Fejlesztési részletek
A Codex feladata:

Létrehozza vagy frissíti a /test/generate_goldens.dart fájlt.

A script minden skin × világos/sötét × fő route-ra külön golden tesztet hoz létre a matchesGoldenFile API-val.

A route-label explicit, pl. "/" helyett home, /settings helyett settings.

Minden PNG a /test/goldens/ mappába kerül, névstruktúra: {routeLabel}_skin{index}_{light|dark}.png.

Bináris fájl (PNG) generálását vagy commitálását a Codex semmilyen körülmények között nem végezheti – csak a scriptet készíti el.

A fejlesztő feladata:

Lefuttatja a Codex által generált scriptet (flutter test --update-goldens).

Manuálisan commitálja a golden PNG-ket a /test/goldens/ mappából.

🧪 Tesztállapot
A /test/generate_goldens.dart script minden kombinációban működik.

PNG-k csak manuális futtatással generálódnak, commit manuális.

A CI pipeline a golden diff alapján csak akkor zöld, ha minden PNG naprakész.

A script nem commitál semmit, csak forrást generál!

🌍 Lokalizáció
A tesztfájl lokalizáció-független, de a generált screenshotokat minden nyelvi beállítás mellett le lehet futtatni.

📎 Kapcsolódások
Sprint4 QA & accessibility workflow következő lépései (T4.2+)

A golden baseline a teljes vizuális és accessibility audit alapja.

⚠️ Kritikus szabály
A Codex soha nem commitálhat bináris fájlt (PNG, screenshot, stb.).

Minden automatikus teszt/golden commit kizárólag manuális fejlesztői feladat!

