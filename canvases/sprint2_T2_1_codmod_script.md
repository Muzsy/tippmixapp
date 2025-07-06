🎯 Funkció
A T2.1 feladat célja egy automatizált codemod script (codemod_replace_hex.dart) elkészítése, amely minden hardcoded hex-színre (0xFFxxxxxx mintákra) rákeres a teljes projektben, és előkészíti azok cseréjét Theme-referenciára. Ez az eszköz az alapja annak, hogy a teljes kódbázisból eltűnjenek a manuális színkódok, és csak a Theme (Material3 + FlexColorScheme) által biztosított, szabványosított színek maradjanak.

🧠 Fejlesztési részletek
Elhelyezkedés: tools/codemods/codemod_replace_hex.dart

Működés:

Regex kereséssel megtalál minden 0xFF[0-9A-F]{6} hex-szín előfordulást.

Minden találatnál heurisztikusan megpróbálja beazonosítani a szín funkcióját (pl. primary, secondary, error, grey stb.), és javaslatot tesz a megfelelő Theme-referencia (pl. Theme.of(context).colorScheme.primary) cseréjére.

Dry-run és apply mód: dry-run esetén csak logot készít a cserélendő helyekről, apply esetén végre is hajtja a cseréket.

Kimenet: módosított kódbázis + log.

Fejlesztési lépések:

Script elkészítése, tesztelése (legalább --help parancssori opció működik).

Dry-run funkció implementálása és logolása.

Előkészítés a T2.2 feladathoz (review).

Elfogadási kritériumok:

A script futtatható, --help működik.

Dry-run logol minden várható cserét.

Kódba semmilyen kézi hex-szín nem kerülhet vissza (CI tiltás, későbbi linter).

🧪 Tesztállapot
Dry-run log futtatása és átnézése.

Script --help paramétere visszaadja az elvárt opciókat.

Hibakezelés implementálva (pl. syntax error esetén figyelmeztetés).

🌍 Lokalizáció
A script csak a kód szintjén működik, nincs közvetlen user-facing lokalizáció.

A log file magyarul és angolul is tartalmazhat leíró sorokat a fejlesztői workflow támogatásához.

📎 Kapcsolódások
Előfeltétel: Sprint1 architektúra (ThemeBuilder, ThemeService, BrandColors) már él.

Közvetlenül kapcsolódik a T2.2 (dry-run review) és T2.3 (apply codemod) feladathoz.

Kimeneteit a teljes widget refaktor (Sprint2) további lépései használják.