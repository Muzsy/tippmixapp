## 📦 FeedService modul

### 🎯 Funkció

A `FeedService` célja, hogy a TippmixApp felhasználói eseményeit (új szelvény, nyeremény, komment, like) rögzítse és megjeleníthetővé tegye egy központi feedben【714289051370818†L0-L4】.  A szolgáltatás támogatja a bővíthető eseménytípusokat, és lehetőséget biztosít a felhasználók számára, hogy mások bejegyzéseire reagáljanak vagy jelentést tegyenek szabálysértő tartalomról【714289051370818†L8-L23】.

### 🧠 Fejlesztési részletek

- Minden feed esemény a `public_feed` Firestore kollekcióba kerül【714289051370818†L8-L9】.
- Az eseménytípusokat a `FeedEventType` enum reprezentálja (`bet_placed`, `ticket_won`, `comment`, `like`)【714289051370818†L8-L13】.
- Minden poszt tartalmaz `userId`, `eventType`, `timestamp`, `message` és `extraData` mezőket【714289051370818†L10-L17】.
- Kommentek alkollekcióban (`feed/{postId}/comments`) tárolódnak, a like‑ok pedig tömbként (`likes: [userId1, userId2, ...]`)【714289051370818†L17-L18】.
- Moderációs funkciók: riport gomb minden bejegyzésen és kommenten; jelentések külön kollekcióba kerülnek【714289051370818†L19-L23】.

### 🧪 Tesztállapot

Az egységtesztek ellenőrzik az események helyes mentését, a komment hozzáadását és annak hosszvalidációját, a saját poszt lájkolásának tiltását és a moderációs riportok mentését【714289051370818†L27-L33】.

### 🌍 Lokalizáció

Az eseménytípusok szöveges azonosítói (`feed_event_bet_placed`, `feed_event_ticket_won`, stb.) minden támogatott nyelvhez definiálva vannak【714289051370818†L36-L46】.

### 📎 Kapcsolódások

- `lib/services/feed_service.dart` – a Dart implementáció.
- `feed_model.dart`, `feed_event_type.dart` – modellek és enumok【714289051370818†L50-L55】.
- Firestore: `public_feed`, `public_feed/{id}/comments`, `moderation_reports`【714289051370818†L51-L55】.
- Codex szabályfájlok: `codex_docs/codex_context.yaml`, `codex_docs/service_dependencies.md`, `codex_docs/localization_logic.md`, `codex_docs/priority_rules.md`【714289051370818†L56-L62】.
- Háttérdokumentumok: `docs/tippmix_app_teljes_adatmodell.md`, `docs/auth_best_practice.md`, `docs/localization_best_practice.md`【714289051370818†L63-L67】.
