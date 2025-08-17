# 🎯 Funkció

A H2H gomboknál a `Home/Draw/Away` kimenetek **korrekt hozzárendelése** (aliasok: `home|1`, `draw|x`, `away|2`) és **biztonságos fallback** az esetekre, amikor a piaci kimenetek sorrendje eltér. A gombfeliratok odds‑kiírása már elkészült; ezt **nem módosítjuk**, csak a hozzárendelést javítjuk.

# 🧠 Fejlesztési részletek

**Érintett fájl:** `tippmixapp-main/lib/widgets/event_bet_card.dart`

* Jelenleg az `_buildH2HButtonsFrom(...)` a kimeneteket **csapatnévhez** hasonlítja (`event.homeTeam`/`event.awayTeam`). A parser viszont `Home/Draw/Away` (vagy `1/X/2`) neveket ad, ezért a hozzárendelés gyakran sikertelen → a címkék `1 — / X — / 2 —` maradnak.

**Változtatások:**

1. **Alias‑alapú hozzárendelés:** `home|1`, `draw|x`, `away|2` felismerése, csapatnév‑összevetés törlése.
2. **Draw fallback (3 kimenetes piacnál):** ha pontosan 3 kimenet van és bármelyik hiányzik, a (0,1,2) sorrend szerint feltöltjük `home/draw/away`‑t. Egyéb esetben megmarad a korábbi „első/utolsó” fallback.
3. **Widget‑teszt frissítés:** a meglévő `event_bet_card_h2h_render_test.dart` a fix `1/X/2` feliratokat kereste; frissítjük `textContaining('1 ')` stb. ellenőrzésekre. Plusz egy új teszt konkrét feliratokra.

# 🧪 Tesztállapot

* **Frissített:** `test/widgets/event_bet_card_h2h_render_test.dart` – odds‑prefixed címkék ellenőrzése.
* **Új:** `test/widgets/event_bet_card_h2h_labels_test.dart` – `1 6.00 / X 4.33 / 2 1.47` feliratok ellenőrzése mock API‑val.
* Futtatás: `flutter analyze --no-fatal-infos lib test` és `flutter test`.

# 🌍 Lokalizáció

* Nem érint lokalizációs kulcsokat; a numerikus oddsok továbbra is a kártyán jelennek meg.

# 📎 Kapcsolódások

* Parser (`MarketMapping.h2hFromApi`) és hálózati réteg (`ApiFootballService`) **változatlan** – ez a patch csak a UI‑ra vonatkozik.

# ✅ Elfogadási kritériumok

* A kártyán a 3 gomb **helyes oddsokkal** jelenik meg, és az onTap‑ok a megfelelő kimenetre hivatkoznak.
* A draw érték nem marad üres, ha a válasz 3 kimenetet tartalmaz sorrendben.
* Minden widget‑teszt zöld.
