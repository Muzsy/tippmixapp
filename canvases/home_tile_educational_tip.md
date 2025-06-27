## 📚 home\_tile\_educational\_tip.md

### 🎯 Funkció

Ez a csempe edukációs célból jelenít meg egy rövid fogadási tippet vagy tanácsot, amely segíti a kezdő felhasználók tájékozódását. A cél, hogy játékos formában tanítsa meg a fogadás alapjait, és bemutassa a haladóbb stratégiákat is.

### 🧠 Fejlesztési részletek

* A tartalom lehet statikus (előre definiált lista) vagy dinamikus (tanulási szinthez igazított tippek)
* Minden megjelenítéskor véletlenszerűen választható egy új edukációs szöveg
* A csempe tartalmazhat egy CTA gombot: „További tippek” → oktató képernyő vagy link

Példa tartalom:

* „Tudtad? Kombinált fogadással több eseményre egyszerre tehetsz tétet, és magasabb oddsszal nyerhetsz.”

### 🧪 Tesztállapot

* Widget teszt: a szöveg megjelenik, lokalizáció rendben van
* Véletlenszerű választás ellenőrzése
* Gomb navigáció működése (ha van oktató képernyő)

### 🌍 Lokalizáció

* Lokalizációs kulcsok:

  * `home_tile_educational_tip_title`: "Fogadási tipp"
  * `home_tile_educational_tip_1`: "Tudtad? Kombinált fogadással magasabb oddsszal nyerhetsz."
  * `home_tile_educational_tip_2`: "Egyszerűbb fogadással (pl. csak egy meccs) kisebb a kockázat."
  * `home_tile_educational_tip_cta`: "További tippek"
* Lokalizáció: `app_hu.arb`, `app_en.arb`, `app_de.arb`

### 📎 Kapcsolódások

* Nincs külső service – lokálisan vagy konfigurációból töltött edukációs szövegek
* Navigation → oktató képernyő vagy tudásbázis (ha elérhető)
* home\_screen.dart → feltételesen mindig megjeleníthető
* Codex szabályzat:

  * codex\_context.yaml
  * localization\_logic.md
  * priority\_rules.md
* Dokumentáció:

  * localization\_best\_practice.md
