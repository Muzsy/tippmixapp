T3.5 – Android dynamic_color integráció
🎯 Funkció
A cél, hogy Android 12+ rendszereken a TippmixApp automatikusan alkalmazkodjon a rendszer színpalettájához (dynamic color), ha a felhasználó ezt engedélyezi. Ha a rendszer-paletta elérhető, akkor az override-olja a felhasználó által választott skin seed-jét; ha nem elérhető (iOS, régi Android), akkor a TippmixApp saját skin logikája aktív marad.

🧠 Fejlesztési részletek
DynamicColorPlugin használata Android 12+ készülékeken, hogy lekérje a rendszer core-palette seed színét.

Az app ThemeBuilder logikájában opcionális fallback:

Ha elérhető a dynamic color seed, ezt használja a skin generálásához.

Ha nem elérhető vagy hiba van, akkor a kiválasztott skin seed színét használja.

Minden platformon (iOS, <12 Android, Web) hibamentesen működik: try-catch védelem, fallback garantált.

A dynamic color támogatás csak Android 12+ verziótól aktív, minden más platformon változatlan a működés.

Teszt: Android 12+ eszközön a rendszer színváltásával együtt frissül az app színsémája, minden más platformon normál skin logika.

🧪 Tesztállapot
Manuális teszt: Android 12+ eszközön a rendszerpaletta váltás után az app is változik.

Automata teszt: Unit/widget teszt a ThemeBuilder dynamic color ágára.

Minden más platformon fallback helyesen működik.

CI pipeline minden teszt sikeres.

🌍 Lokalizáció
Hibaüzenetek (ha vannak) magyarul és angolul is jelennek meg.

A funkció működése a felhasználónak platformfüggetlen; UI-ban nincs szükség új szövegre.

📎 Kapcsolódások
T3.1–T3.4: Skin builder és állapotkezelés.

ThemeBuilder: Dynamic color integráció.

Platform channel: Android specifikus hívások.

Tesztelés: Platformfüggő viselkedés igazolása.