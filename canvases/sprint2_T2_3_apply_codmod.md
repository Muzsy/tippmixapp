🎯 Funkció
A T2.3 feladat célja, hogy a color_audit_reviewed.csv alapján, kizárólag az automatikusan cserélhető színhasználatok (hex, Colors.*) helyén végrehajtsuk a Theme/ThemeExtension refaktort. A cseréket követően a projekt kódjából eltűnnek a manuális színek azon részei, amelyek egyértelműen theme-re hivatkozhatnak. Az eredményt commitoljuk, majd auditáljuk (újabb color_audit futtatása).

🧠 Fejlesztési részletek
Bemenet:

color_audit_reviewed.csv

Csak azok a sorok, ahol automatikusan cserélhető Theme-referencia van hozzárendelve (nem kell manuális refaktor).

Művelet:

Codemod script vagy kézi refaktor alapján minden jelölt sorban hajtsd végre a cserét: Colors.* → Theme.of(context).colorScheme.*, ThemeExtension, stb.

A manual_color_refactors.txt-ben jelölt helyeket hagyd ki!

A refaktor után commitáld a változtatásokat.

Ellenőrzés:

Futtasd újra a color_audit scriptet: ha mindent jól cseréltél, már csak manuális beavatkozást igénylő sorok maradhatnak (vagy teljesen üres lesz a lista).

Ellenőrizd, hogy a linter szabályai (avoid-hard-coded-colors) nem dobnak hibát az automatikusan refaktorált kódra.

🧪 Tesztállapot
color_audit.csv futtatása után csak a manualisan jelölt sorok szerepelnek, minden automatikusan cserélhető eltűnt.

Linter warning = 0 automatikus refaktor helyeken.

Commit log, diff ellenőrizve.

🌍 Lokalizáció
Csak fejlesztői workflow, nincs user-facing lokalizáció.

📎 Kapcsolódások
Előzmény: T2.2 (color_audit_reviewed.csv, manual_color_refactors.txt)

Következő lépés: T2.4 (manuális refaktor, bonyolult színek, brand/generic grey stb.)

Utána: Linter, golden test, a11y, végső audit.