# Fogadási oldal – UI/UX finomítások (filter & kártya)

## 🎯 Funkció

A fogadási oldal vizuális egységesítése és felhasználói élményének javítása az alábbi tételekkel:

1. Szűrő gombok stílusának egységesítése a tippkártyán használt gombokhoz.
2. Szűrősáv háttér finomítása (surfaceVariant + rendezett padding).
3. Országváltáskor liga‑lista frissülésének finom animációja (fade).
4. Kezdési időpont félkövér, visszaszámlálás secondary színnel a kártyán.
5. Térközök optimalizálása a kártyán (kompaktabb elrendezés).
6. Tippgombok kétsoros elrendezése: felül "Hazai | Döntetlen | Vendég", alul az odds félkövérrel; aktív állapotnál szegély.
7. Betöltés jelző a lista frissítésénél; üres/hiba állapotnál ikon + segítő szöveg.

## 🧠 Fejlesztési részletek

* **Érintett fájlok:**

  * `lib/widgets/events_filter_bar.dart` – filter UI, hátterezés, animáció, gomb egységesítés.
  * `lib/widgets/event_bet_card.dart` – idő- és visszaszámláló stílus, térköz, tippgombok kétsoros elrendezése + aktív border.
  * `lib/screens/events_screen.dart` – betöltés jelző és üres állapot ikon+szöveg.
* **Komponensek:** a dátumválasztóhoz `ActionPill` (a kártyák gombstílusával konzisztens), a ligaválasztó frissítése `AnimatedSwitcher`‑rel.
* **Stílus:** Material 3 színek – `surfaceVariant`, `colorScheme.secondary` a countdown szöveghez.

## 🧪 Tesztállapot

* Widget snapshot: tippgombok kétsoros elrendezése és aktív border megjelenése.
* Golden: filter sáv (surfaceVariant háttér, új padding), animations smoke test.
* Állapotkezelés: Loading → progress indikátor; Empty → ikon + szöveg.

## 🌍 Lokalizáció

* Nincs új kulcs kötelezően. (Az üres állapot segítő szöveg felhasználja a meglévő „Nincs esemény”/lokalizált kulcsot, csak ikon társul.)

## 📎 Kapcsolódások

* Előzmény: `canvases/betting_page_filters_reset.md` (Dropdown assert javítás, reset logika)
* Szabály: **Codex Canvas Yaml Guide.pdf**
