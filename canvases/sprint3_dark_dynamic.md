Sprint 3 – Dark Mode & Dinamikus Skinek
T3.1 – ThemeService perzisztencia réteg kiterjesztése
🎯 Funkció
A feladat célja, hogy a TippmixApp színséma- és dark mode beállításait tartósan (perzisztensen) kezelje. Ehhez a ThemeService bővítésre kerül úgy, hogy a felhasználó által választott skin és dark mód állapot mentése és visszatöltése működjön helyi (SharedPreferences) és felhő (Firestore) tárolóból is. Ez lehetővé teszi, hogy az app újraindításakor, illetve különböző eszközökön is egységes legyen a megjelenés minden bejelentkezett user számára.

🧠 Fejlesztési részletek
SharedPreferences integráció: skin index és dark mode flag lokális mentése, olvasása.

Firestore szinkronizáció: bejelentkezett felhasználóknál a beállítások szinkronizálása a users/{uid}/settings/theme dokumentumba.

Új ThemeService metódusok:

hydrate() – app induláskor betölti a beállításokat (helyi vagy cloud forrásból)

saveTheme() – a skin váltás mentése (mindkét forrásba)

saveDarkMode() – dark mode állapot mentése (mindkét forrásba)

Állapotkezelés: Minden változás automatikusan frissíti a UI-t (Riverpod/Provider logika szerint).

CI követelmény: Unit-teszt minden új metódushoz.

🧪 Tesztállapot
Manuális és automata tesztek:

Skin/dark mód beállítás változtatása után újraindítva az appot, a választás megmarad.

Bejelentkezés után a beállítás Firestore-ból helyesen visszatöltődik.

Kijelentkezés → local storage alapértelmezett értékekre visszaáll.

CI pipeline-ban minden teszt zöld.

🌍 Lokalizáció
Nincsenek közvetlenül lokalizálandó sztringek ebben a feladatban.

Skin nevek/azonosítók későbbi lépésben kerülnek lokalizálásra.

Hibaüzenetek (ha vannak) magyar és angol nyelven.

📎 Kapcsolódások
Sprint1: ThemeService alapszolgáltatásai

Sprint2: Widgetek már csak ThemeService-ből kapnak színt

T3.2–T3.6: Minden további sprint3-as lépés ehhez a perzisztencia logikához kötődik

Firestore, SharedPreferences: integrációs pontok

CI pipeline: Teszt, audit és minőségbiztosítás kapcsolódik hozzá