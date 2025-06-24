## 🎯 Funkció

A `CopyBetFlow` célja, hogy a feedből kiválasztott fogadási eseményeket a felhasználó saját szelvényként másolhassa, majd később tetszés szerint módosíthassa, kiegészíthesse, és csak ezután adja fel.

---

## 🧠 Fejlesztési részletek

* A másolt szelvények Firestore-on belül a `copied_bets/{userId}/{copyId}` kollekcióba kerülnek.
* A másolás nem eredményez automatikus fogadást.
* A felhasználó a `CopiedTicketEditScreen` képernyőn szerkesztheti a szelvényt.
* A logika tartalmazza:

  * Eredeti ticketId, tippek listája
  * `createdAt` timestamp
  * `wasModified` flag (ha a felhasználó belenyúlt)
* Felhasználói interakció menete:

  * Feed poszton „Másolás” gomb → sikerüzenet és Firestore írás
  * „Másolt szelvényeim” szekció a profilban / külön menüpontban
  * Innen szerkeszthető vagy törölhető
  * „Feladás” gomb csak érvényes, módosított szelvénynél aktív

---

## 🧪 Tesztállapot

* [ ] Unit test: másolási logika (helyes adatmentés, userId és ticketId ellenőrzés)
* [ ] Widget test: `CopiedTicketEditScreen` felület működése, módosítás engedélyezése
* [ ] Érvényesítés: csak módosított szelvény legyen feladható

---

## 🌍 Lokalizáció

Szükséges kulcsok:

* `copy_success` → „Szelvény másolva!”
* `copy_edit_title` → „Másolt szelvény szerkesztése”
* `copy_submit_button` → „Szelvény feladása”
* `copy_invalid_state` → „A szelvény nem módosult, így nem adható fel.”

---

## 📎 Kapcsolódások

* `lib/flows/copy_bet_flow.dart`
* `lib/screens/copied_ticket_edit_screen.dart`
* Firestore: `copied_bets/{userId}/{copyId}`

**Codex szabályfájlok:**

* `codex_docs/codex_context.yaml`
* `codex_docs/service_dependencies.md`
* `codex_docs/localization_logic.md`
* `codex_docs/priority_rules.md`

**Háttérdokumentumok:**

* `docs/betting_ticket_data_model.md`
* `docs/tippmix_app_teljes_adatmodell.md`
* `docs/localization_best_practice.md`
