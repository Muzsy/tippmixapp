# LoginRegisterScreen – Sprint 4: Teljes tesztlefedettség, hibakezelés, lokalizáció (háromnyelvű, bináris tiltás)

## 🎯 Funkció

A login/regisztrációs képernyő összes fejlesztett flow-jának (emailes, social, verifikáció, jelszó-visszaállítás) teljes körű tesztelése, hiba- és edge-case kezelés, valamint a háromnyelvű lokalizáció véglegesítése. Bináris fájlok kezelése minden lépésnél tiltott.

## 🧠 Fejlesztési részletek

* Minden login-regisztrációs és social login flow végigtesztelése: siker, hiba, edge-case, visszalépés.
* Hibaüzenetek, sikeres flow-k UI/UX tesztje, valós felhasználói szituációkkal.
* Lokalizációs fájlok végleges feltöltése: minden új szöveg, hibaüzenet, státusz (HU/EN/DE)
* Accessibility (hozzáférhetőség) szempontok áttekintése, billentyűzet navigáció, kontraszt, képernyőolvasó támogatás.
* Felhasználói visszajelzések alapján finomhangolás (UI, hibakezelés).
* Bináris fájl létrehozása, generálása, commithoz adása *szigorúan TILOS* minden tesztnél, automatizált folyamatnál is.

## 🧪 Tesztállapot

* Widget, integrációs és end-to-end tesztek minden flow-ra
* Lokalizáció teszt (háromnyelvűség minden esetben)
* Accessibility és hibakezelés tesztelése

## 🌍 Lokalizáció

* Lokalizációs fájl véglegesítése, minden folyamat szövegének háromnyelvű tesztje

## 📎 Kapcsolódások

* login\_register\_screen.dart, auth\_service.dart (összes flow)
* test fájlok (widget, integráció, e2e)
* localization fájlok (háromnyelvű)
