# MyTickets (Szelvényeim) – UI Refactor Spec

Ez a dokumentum a MyTickets képernyő vizuális és UX finomítását rögzíti a **Material 3 + FlexColorScheme** témaelvek szerint. A cél a státusz-chipek egységesítése, a csempe (listaelem) információ‑architektúrájának bővítése, és a részletező dialógus átstrukturálása.

---

## 🎯 Célok

1. **Egységes státusz-chipek** (Nyert/Veszített/Függőben) a `colorScheme`‑ből felépítve, AA kontraszt mellett.
2. **Informatívabb TicketCard**: „Várható nyeremény” kiemelése, metaadatok konszolidálása, státusz vizuális jel (színes sáv).
3. **Részletező dialógus csoportosítással**: nyertes/vesztes/függőben tippek külön szekciókban, összecsukható listákkal.
4. **Barátságos azonosító** a nyers `doc.id` helyett (pl. „Szelvény #4755”), a teljes ID másolása menüből.
5. **Lokalizáció + A11y** frissítések, **Golden tesztek** világos/sötét témára.

---

## 🧱 Érintett komponensek (a jelenlegi screen\_spec.md alapján)

* `lib/widgets/ticket_status_chip.dart`
* `lib/widgets/ticket_card.dart`
* `lib/widgets/ticket_details_dialog.dart`
* (Teszt) `test/widget/…` és `integration_test/…` – bővítendő

> Megjegyzés: a pontos fájlnevek/útvonalak a repó aktuális állapota szerint igazítandók.

---

## 🎨 Státusz-chip (TicketStatusChip) – vizuális szabályok

* **Színek** (témából):

  * **Nyert** → `colorScheme.primaryContainer` háttér, `onPrimaryContainer` szöveg/ikon.
  * **Veszített** → `errorContainer` háttér, `onErrorContainer` szöveg/ikon.
  * **Függőben** → `secondaryContainer` háttér, `onSecondaryContainer` szöveg/ikon.
* **Méretezés**: min. magasság 32dp; vízszintes padding 12–16dp; `shape` kerekített (8dp).
* **Tipográfia**: `labelMedium` (vagy `labelLarge`, ha prioritásos). Félkövér csak státusz‑kiemeléshez.
* **Ikon** (opcionális, 16dp): ✅ / ✖️ / ⏳; `IconTheme` a chipen belül örökli a `on*Container` színt.
* **A11y**: semanticsLabel minta: „Státusz: Nyert”.

---

## 🧩 TicketCard – információ‑architektúra

* **Kétoszlopos elrendezés**:

  * **Bal**: „Tét • Össz. odds • Tippek száma” egy meta‑sorban; alatta „Dátum” (létrehozva/utolsó módosítás – pontos címkével).
  * **Jobb**: nagy tipográfiával „Várható nyeremény”; alatta a státusz‑chip.
* **Vizuális jel**: 2–4dp széles bal oldali sáv a státusz színével.
* **Számformátum**: lokalizált (HU: vessző tizedesjel), fix 2 tizedes.
* **Spacing**: 12–16dp belső padding; `Divider(color: colorScheme.outlineVariant)` a tételek közt.
* **A11y**: a kártya teljes tartalma beszédesen felolvasható (stake, odds, tips, status, potentialWin).

---

## 🪟 Részletező dialógus – szerkezet

* **Fejléc**: `titleLarge` + `ticket_friendly_id` (pl. „Szelvény #4755”). A teljes `doc.id` csak ⋮ menüben „ID másolása”.
* **Összegző blokk**: Tét, Össz. odds, Várható nyeremény, Dátum(ok), Tippek száma, Állapot‑chip.
* **Szekciók** (összecsukhatók):

  * **Nyertes tippek (N)**
  * **Vesztes tippek (N)**
  * **Függőben lévő tippek (N)\`**
* **Listaelem (tipp)**: Esemény cím (fő sor) • `market/outcome` (alsó sor); jobb oldalt állapot‑chip + `×odds`.
* **„Odds: 1.0” anomália**: ha fallback/érvénytelen, jelenjen meg „–” vagy a tényleges eredeti odds; ne félrevezető „1.00”.

---

## 🌍 Lokalizáció (minimum)

* `ticket_status_won`, `ticket_status_lost`, `ticket_status_pending`
* `ticket_friendly_id` → „Szelvény #{}”
* `ticket_details.section_won`, `.section_lost`, `.section_pending`
* `ticket_meta_created`, `ticket_meta_updated`, `ticket_potential_win`, `ticket_total_odd`, `ticket_stake`

---

## 📊 Telemetria

* `tickets_list_chip_tapped` (status)
* `ticket_details_group_toggled` (group: won/lost/pending, expanded: bool, count)
* `ticket_details_item_viewed` (eventId/outcome)

---

## ✅ Elfogadási kritériumok (AC)

* **AC1**: A státusz‑chipek a `colorScheme` megfelelő *Container* + *onContainer* párosát használják, AA kontraszttal.
* **AC2**: A TicketCard jobb oszlopában nagy kiemeléssel látszik a „Várható nyeremény”.
* **AC3**: A részletező dialógus tippei státusz szerinti szekciókban, darabszámmal és összecsukható listával jelennek meg.
* **AC4**: A felhasználóbarát azonosító jelenik meg (a nyers `doc.id` nem zavarja a UI‑t); ID másolása elérhető a menüből.
* **AC5**: Golden tesztek (világos/sötét) a három státusz‑chipre és egy részletező nézetre; HU/EN/DE kulcsok léteznek.

---

## 🧪 Tesztelési terv (részlet)

* **Widget**: három chip variáns kontraszt‑ és méretaudit, TicketCard layout, dialógus csoportosítás/összecsukás.
* **I18n**: ellenőrző teszt, hogy a fenti kulcsok fordításai megvannak HU/EN (DE opcionális most).
