## 🎯 Funkció

A `HomeFeedWidget` komponens célja, hogy a `public_feed` kollekcióban tárolt eseményeket felhasználóbarát módon megjelenítse egy lapozható, shimmer loaderrel támogatott UI felületen. A felhasználók lájkolhatják, kommentelhetik vagy jelenthetik az egyes bejegyzéseket.

---

## 🧠 Fejlesztési részletek

* A komponens a `lib/widgets/home_feed.dart` fájlban található.
* Firestore streamet használ `orderBy('timestamp', descending: true).limit(100)` lekérdezéssel.
* Infinite scroll: újabb adatok `startAfterDocument` alapján töltődnek be.
* Minden feed elem kártyán jelenik meg, tartalmazza:

  * Felhasználónév vagy UID
  * Üzenet (max 250 karakter)
  * Eseménytípus ikon vagy szín
  * Lájk gomb (ha nem saját poszt)
  * Kommentek száma + komment gomb
  * Jelentés ikon
* Komponens belső shimmer loaderrel indul, amíg a stream be nem tölt.
* Üres állapot üzenet: „Nincsenek megjeleníthető események.”
* Like gomb tiltva, ha a `currentUserId == post.userId`
* Kommentre tappolva modal nyílik meg (`CommentModal`)
* Report gombra nyitott `reportDialog` jelentés ok kiválasztással

---

## 🧪 Tesztállapot

* [ ] Widget test shimmer loaderre (initial load)
* [ ] Teszt feed elem renderelésre (minden eventType-ra)
* [ ] Saját poszt like gomb tiltás teszt
* [ ] Komment gomb működésének tesztje
* [ ] Üres állapot teszt

---

## 🌍 Lokalizáció

A következő kulcsokat használja a komponens:

* `feed_empty_state` → „Nincsenek megjeleníthető események.”
* `feed_like` → „Kedvelés”
* `feed_comment` → „Hozzászólás”
* `feed_report` → „Jelentés”

---

## 📎 Kapcsolódások

* `lib/widgets/home_feed.dart`
* `feed_service.dart` → feed stream lekérdezése, report meghívása
* `feed_model.dart`, `feed_event_type.dart`
* UI komponensek: `CommentModal`, `ReportDialog`

**Codex szabályfájlok:**

* `codex_docs/codex_context.yaml`
* `codex_docs/localization_logic.md`
* `codex_docs/service_dependencies.md`
* `codex_docs/priority_rules.md`

**Háttérdokumentumok:**

* `docs/localization_best_practice.md`
* `docs/tippmix_app_teljes_adatmodell.md`
