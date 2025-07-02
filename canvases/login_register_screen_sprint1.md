# LoginRegisterScreen – Sprint 1: UI redesign és csempés struktúra (háromnyelvű)

## 🎯 Funkció

A login/regisztrációs képernyő teljes újratervezése, csempés, vizuálisan átlátható, bővíthető felülettel, amely a későbbi SSO és extra funkciókat is előkészíti. A cél a felhasználói élmény radikális javítása, a modern Material Design alapelvek mentén.

## 🧠 Fejlesztési részletek

* Felső blokkban app logó, köszöntő szöveg (pl. "Üdv a TippmixApp-ban!").
* Középső szekcióban nagy, elkülönített csempék:

  * Email alapú belépés/regisztráció
  * (SSO helyeknek előkészített, de egyelőre inaktív csempék)
* Material Design input mezők, letisztult formában.
* Csempék között animált tranzíciók (pl. váltás login/regisztráció között).
* Alsó blokkban „Jelszó-visszaállítás” link, help/support gomb.
* Hibaüzenetek és státuszok vizuális megjelenítése (alap snackbar/dialog).
* Lokalizációs kulcsok minden új szöveghez (HU/EN/DE előkészítés).
* Widgetek szerkezeti tagolása (CustomLoginTile, CustomInputField).

## 🧪 Tesztállapot

* UI widget tesztek alap login/regisztrációs flow-ra.
* Csempék és inputok hibakezelésének ellenőrzése.
* Navigációs flow tesztje.
* Lokalizációs teszt (alapszövegek, váltás nyelv között, három nyelvvel: HU/EN/DE).

## 🌍 Lokalizáció

* Minden új szöveg/felirat kulccsal bekerül a lokalizációs fájlba.
* Három nyelv támogatása előkészítve (HU/EN/DE).

## 📎 Kapcsolódások

* profile\_screen.dart (UI struktúra mintája)
* custom\_widgets.dart (új vagy módosított widgetek)
* login\_register\_screen.dart (fő képernyő)
* auth\_service.dart (login/regisztráció logika, de most csak UI érintett)
