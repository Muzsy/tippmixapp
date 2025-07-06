T3.6 – Persist & hydrate on startup (Beállítások betöltése app induláskor)
🎯 Funkció
A cél, hogy a TippmixApp minden indításakor automatikusan visszatöltse a legutóbb használt skin és dark mode beállításokat (helyi vagy felhőből), így a felhasználó mindig a saját, korábban választott kinézettel találkozik. A fő alkalmazás csak az összes theme-beállítás sikeres betöltése után indul el.

🧠 Fejlesztési részletek
Az app indításakor (main()) első lépésben meghívódik a ThemeService.hydrate(), amely betölti a skin indexet és a dark mode állapotot (SharedPreferences/Firestore).

Splash screen vagy loading state jelenik meg, amíg a beállítások nem töltődtek be teljesen.

A betöltés után a MaterialApp a helyes theme/darkTheme állapottal indul el.

Hibakezelés: ha a beállítások betöltése sikertelen, alapértelmezett skin/dark állapot lép életbe.

Minden perzisztens theme-váltás (T3.1–T3.5) helyesen működik indulás után is.

Teszt: indulás után a user ugyanazt a megjelenést kapja, mint amit korábban kiválasztott.

🧪 Tesztállapot
Manuális teszt: többszöri újraindítás után is megmarad a választott skin/dark mód.

Automata teszt: ThemeService.hydrate() unit/widget teszt, hibakezelés tesztelése.

CI pipeline minden teszt sikeres.

🌍 Lokalizáció
Hibák, státuszok, loading szövegek lokalizáltak (magyar/angol).

UI feliratokat csak érintőlegesen érint (splash/loading).

📎 Kapcsolódások
T3.1: Perzisztencia réteg

T3.2–T3.5: Minden váltás állapotának mentése/visszatöltése

main.dart: App indítási logika

SplashScreen: Loading state

Tesztelés: Induláskori state és fallback működés