# Fogadási oldal – H2H fix címkék és szelvény ürítés beküldés után

🎯 **Funkció**

* H2H gombok felirata fix, lokalizált szöveg legyen: **Hazai / Döntetlen / Vendég** (nyelvfüggően `home_short`, `draw_short`, `away_short`).
* „Fogadás leadása” után az aktuális szelvény **törlődjön**, az app **visszanavigáljon** a fogadások képernyőre, és jelenjen meg egy rövid üzenet: **„Szelvény beküldve”**.

🧠 **Fejlesztési részletek**

* **Érintett fájlok** (a feltöltött `tippmixapp.zip` alapján):

  * `lib/widgets/event_bet_card.dart` – H2H gombsor és `_oddsButton(...)`.
  * `lib/screens/create_ticket_screen.dart` – szelvény beküldés logika.
  * `lib/l10n/app_hu.arb` – HU üzenet szövege.
* **H2H fix feliratok**:

  * Az `_oddsButton` kap egy opcionális `fixedLabel` paramétert; ha meg van adva, ezt írjuk ki, különben marad a meglévő `pretty(o.name)`.
  * A `_buildH2HButtons(...)` metódusban a három gombnál átadjuk a `loc.home_short`, `loc.draw_short`, `loc.away_short` feliratokat.
  * Az ARB‑ekben már léteznek a rövid kulcsok (`home_short`, `draw_short`, `away_short`), **új kulcs nem kell**.
* **Szelvény törlés & navigáció**:

  * A sikeres beküldés után hívjuk: `ref.read(betSlipProvider.notifier).clearSlip();` majd SnackBar, végül vissza (`Navigator.pop()` a jelenlegi stack szerint elegendő).
  * A HU üzenet értékét a kéréssel összhangban rövidítjük: `"Szelvény beküldve"`.

🧪 **Tesztállapot**

* Manuális ellenőrzési lista:

  1. H2H gombok feliratai a nyelvnek megfelelően **Hazai / Döntetlen / Vendég** (és EN/DE alatt is a rövid címkék).
  2. Legalább egy tipp kiválasztása után megjelenik a FAB → „Szelvény készítése” képernyőre megy.
  3. Tét megadása és „Fogadás leadása” után SnackBar: **„Szelvény beküldve”**.
  4. Visszakerülünk a fogadások képernyőre, a szelvény **üres**, a FAB eltűnik (mert nincs tip).
* CI: `flutter gen-l10n`, `flutter analyze`, releváns widget/service tesztek futnak zölden.

🌍 **Lokalizáció**

* Kulcsok: `home_short`, `draw_short`, `away_short` – **már léteznek** HU/EN/DE nyelveken.
* `ticket_submit_success` HU érték módosul: **„Szelvény beküldve”** (EN/DE változatlan).

📎 **Kapcsolódások**

* Codex YAML: `/codex/goals/canvases/fill_canvas_bet_h2h_fixed_labels_and_ticket_clear.yaml` (ez a vászon kiegészítője, pontos diffekkel)
* Dokumentumok: `Codex Canvas Yaml Guide.pdf` (séma és szabályok)

---

**Készre jelentés feltételei**

* [ ] H2H gombokon fix lokalizált feliratok jelennek meg.
* [ ] Sikeres beküldés után a szelvény törlődik és visszanavigál az app.
* [ ] SnackBar HU: „Szelvény beküldve”.
* [ ] `flutter analyze` hibamentes; l10n generálva.
