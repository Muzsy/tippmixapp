# 🎯 Funkció

A főmenü (Drawer) minden képernyőn elérhető és megnyitható legyen, ne csak a főképernyőn. Ezáltal a felhasználó bármikor könnyen elérheti a navigációs menüpontokat, függetlenül attól, hogy éppen melyik képernyőn tartózkodik.

# 🧠 Fejlesztési részletek

* A jelenlegi megvalósításban a `Scaffold.drawer` csak root route-on (főképernyőn) van beállítva, minden más oldalon hiányzik.
* Megoldás: a drawer legyen mindig beállítva, minden képernyőn, ahol a főnavigáció fut.
* A változtatás elsődlegesen a `lib/screens/home_screen.dart` vagy az azt vezérlő shell komponens(ek) módosítását igényli.
* Az `_isRootRoute(context)` ellenőrzést törölni/kikerülni, a drawer-t fixen adjuk át.
* Ellenőrizni kell, hogy a drawer megnyitása animációja és viselkedése (például swipe vissza, vagy gombnyomásra megnyitás) minden képernyőn konzisztens maradjon.
* A teszteseteket (widget test, integration test) módosítani kell, ahol elvárt volt, hogy nincs drawer.

# 🧪 Tesztállapot

* Manuális teszt: minden képernyőn próbáljuk ki a drawer megnyitását (ikonra kattintás, swipe).
* Widget tesztek: drawer jelenlétének ellenőrzése különböző route-okon.
* QA: menüpontok működésének ellenőrzése (navigáció, kijelentkezés, stb.).

# 🌍 Lokalizáció

* Nincs lokalizációs érintettség.

# 📎 Kapcsolódások

* Érintett fájlok: `lib/screens/home_screen.dart`, esetleg shell/sablon widgetek.
* Widget tesztek.
* Navigációs logika, minden menüpont, ami drawer-ből indul.

---

## Megjegyzés

Ha a drawer speciális feltételektől függene (pl. nem minden képernyőn szabad megjeleníteni), ezt a logikát egy külön szabályban vagy wrapper komponensben kellene kezelni. Alapértelmezésben viszont minden fő route-on legyen látható.
