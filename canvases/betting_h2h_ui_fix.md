# 🎯 Funkció

A fogadási kártyák H2H (1X2) gombjain **jelenjenek meg az odds értékek** (pl. `1 1.85`, `X 3.30`, `2 4.20`), és a kimenetek hozzárendelése a JSON‑ból **konzisztensen Home/Draw/Away szerint** történjen – ne csapatnév‑egyezés alapján.

* A hálózati és parsing réteg **nem változik** (már most is jól működik).
* Csak az UI kártyakomponens kerül finomításra.

# 🧠 Fejlesztési részletek

**Érintett fájlok (zip alapján):**

* `tippmixapp-main/lib/widgets/event_bet_card.dart`

  * `_buildH2HButtons(...)`: a 3 ActionPill jelenleg fix címkékkel (`'1'`, `'X'`, `'2'`).
  * `_buildH2HButtonsFrom(...)`: a H2H kimenetek párosítása csapatnévhez próbál igazodni, ami a jelenlegi parserrel nem stabil.
* Parser: `tippmixapp-main/lib/services/market_mapping.dart`

  * A H2H mappelés már jól ad vissza `Home/Draw/Away`/`1/X/2` neveket → **ehhez** igazítjuk a kártyát.
* Tesztek:

  * `tippmixapp-main/test/widgets/event_bet_card_h2h_render_test.dart` – jelenleg a `'1'/'X'/'2'` szövegeket keresi.

**Változtatások:**

1. **Odds kiírás a gombcímkékben**
   A 3 ActionPill címkéje `"1 ${price}"`, `"X ${price}"`, `"2 ${price}"` formát kap (két tizedesre kerekítve). A gombok továbbra is letiltanak, ha az adott kimenet hiányzik.
2. **Kimenet‑párosítás javítása**
   `_buildH2HButtonsFrom(...)` a kimeneteket `home|1`, `draw|x`, `away|2` aliasok szerint párosítja, **nem** a csapatnevekhez.
3. **Tesztfrissítés és új teszt**

   * A meglévő render tesztet frissítjük, hogy az új címkét fogadja.
   * Új teszt ellenőrzi a konkrét feliratokat (pl. `1 6.00`, `X 4.33`, `2 1.47`).

# 🧪 Tesztállapot

**Új/Frissített tesztek:**

* `event_bet_card_h2h_render_test.dart`: a `'1'/'X'/'2'` helyett a címke **oddssal** együtt kerül ellenőrzésre.
* `event_bet_card_h2h_labels_test.dart`: mock API‑val egzakt felirat‑ellenőrzés (`1 6.00`, `X 4.33`, `2 1.47`).

**Futtatás:**

* `flutter analyze --no-fatal-infos lib test`
* `flutter test`

# 🌍 Lokalizáció

* A címkék numerikus oddsokat jelenítenek meg; lokalizációs kulcs nem változik.
* Tizedespont formátuma a platform alapértelmezésével megegyező (Dart `toStringAsFixed(2)`).

# 📎 Kapcsolódások

* **Network/Service/Mapper**: változatlan (`ApiFootballService`, `MarketMapping`).
* **Kártya működés**: továbbra is lokális‑első; H2H hiányában próbál lekérni.

---

**Elfogadási kritériumok**

* A kártyán mindhárom gomb felirata tartalmazza az odds értéket, ha elérhető.
* A gombok a helyes kimenetre (`Home/Draw/Away`) mutatnak.
* Minden teszt zölden fut; nincs regresszió a képernyőn (csak felirat bővül).
