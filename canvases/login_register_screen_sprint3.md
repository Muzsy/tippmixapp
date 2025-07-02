# LoginRegisterScreen – Sprint 3: Email regisztráció, email-verifikáció, jelszó-visszaállítás (háromnyelvű)

## 🎯 Funkció

A klasszikus email-alapú regisztráció és bejelentkezési funkciók professzionális, biztonságos megvalósítása, email-cím megerősítési (verifikációs) folyamattal, jelszó-visszaállítás lehetőséggel, mindez háromnyelvű támogatással és bináris fájlok tiltásával.

## 🧠 Fejlesztési részletek

* Email alapú regisztráció/belépés továbbfejlesztése: validáció, hibaüzenetek, UX.
* Email-cím megerősítése (verifikáció): regisztráció után email küldése, verifikációs státusz kezelése, egyértelmű felhasználói visszajelzések.
* Jelszó-visszaállítás lehetősége: "elfelejtett jelszó" link, emailes reset flow.
* Hibakezelés minden folyamatban: validációs hiba, sikertelen emailküldés, nem verifikált státusz stb.
* Minden üzenet és hibaüzenet háromnyelvű (HU/EN/DE) lokalizációval.
* Bináris fájl (pl. kép, ikon, pdf, stb.) létrehozása TILOS!

## 🧪 Tesztállapot

* Email regisztráció és belépés UI tesztek
* Email-verifikáció és jelszó-visszaállítás teljes flow tesztje
* Lokalizációs tesztek (háromnyelvűség minden felületen)
* Hibaüzenetek és edge-case-ek tesztelése

## 🌍 Lokalizáció

* Új emailes flow-hoz kapcsolódó összes szöveg/felirat háromnyelvű (HU/EN/DE) lokalizációs kulccsal

## 📎 Kapcsolódások

* login\_register\_screen.dart (UI, flow)
* auth\_service.dart (emailes autentikáció, verifikáció, password reset)
* localization fájlok (új kulcsok, háromnyelvűen)
