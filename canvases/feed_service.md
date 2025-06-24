## 🎯 Funkció

A `FeedService` modul célja, hogy a TippmixApp felhasználói eseményeit (új szelvény, nyeremény, komment, like) rögzítse és megjeleníthetővé tegye egy központi feedben. A rendszer támogatja a bővíthető eseménytípusokat, és lehetőséget biztosít a felhasználók számára, hogy mások bejegyzéseire reagáljanak, valamint jelentést tegyenek szabálysértő tartalomról.

---

## 🧠 Fejlesztési részletek

* Minden feed esemény a `public_feed` Firestore kollekcióba kerül mentésre.
* Eseménytípusokat a `FeedEventType` enum reprezentálja (`bet_placed`, `ticket_won`, `comment`, `like`), külön fájlban (feed\_event\_type.dart).
* Minden feed poszt tartalmazza:

  * `userId`
  * `eventType`
  * `timestamp`
  * `message`
  * `extraData` (pl. ticketId, betId)
* Kommentek alkollekcióban: `feed/{postId}/comments`
* Like-k tárolása tömbként: `likes: [userId1, userId2, ...]`
* Moderáció:

  * `report` gomb minden bejegyzésen és kommenten
  * Jelentések külön kollekcióba: `moderation_reports/`
  * Moderátor csak akkor láthatja, ha `role: moderator` a Firestore user dokumentumban

---

## 🧪 Tesztállapot

* [ ] Unit test: események helyes mentése (`addFeedEntry`)
* [ ] Komment hozzáadás és hosszvalidáció (max 250 karakter)
* [ ] Saját poszt lájkolásának tiltása tesztelve
* [ ] Moderációs riport bejegyzés mentése valid adatokkal

---

## 🌍 Lokalizáció

Az alábbi lokalizációs kulcsokat szükséges felvenni minden nyelvhez:

* `feed_event_bet_placed`
* `feed_event_ticket_won`
* `feed_event_comment`
* `feed_event_like`
* `feed_report_success` → "A bejegyzést jelentettük moderátorainknak."

A megjelenítés nyelvfüggő, `AppLocalizationsKey` alapú kulcsokkal.

---

## 📎 Kapcsolódások

* `lib/services/feed_service.dart`
* `lib/models/feed_model.dart`, `feed_event_type.dart`
* Firestore: `public_feed`, `public_feed/{id}/comments`, `moderation_reports`

**Codex szabályfájlok:**

* `codex_docs/codex_context.yaml`
* `codex_docs/service_dependencies.md`
* `codex_docs/localization_logic.md`
* `codex_docs/priority_rules.md`

**Háttérdokumentumok:**

* `docs/tippmix_app_teljes_adatmodell.md`
* `docs/auth_best_practice.md`
* `docs/localization_best_practice.md`
