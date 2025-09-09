# Fórum modul – Moderator & Aggregation fixup (2025‑09‑09)

🎯 **Funkció**
A fórum modul moderátori funkcióinak (pin/lock) és a szerveroldali szavazat‑aggregációnak (votesCount) a véglegesítése, a jelenlegi P0 jogosultsági eltérés kijavítása, valamint a hiányzó E2E teszt és moderátor‑claim bekötés pótlása. Cél: konzisztens szabályok, hibamentes UI, lefedett tesztek.

---

🧠 **Fejlesztési részletek**

* **P0: Törlés jogosultság – UI ↔ rules összehangolása**

  * A `PostItem` jelenleg tulajdonosnak is mutat törlés gombot, miközben a Firestore rules csak moderátornak engedi.
  * **Megoldás (B)**: rejtett törlés gomb **minden nem‑moderátornál** + kontroller szintű védelem.
  * Guard a hívási rétegben (repo) is: nem‑moderátornál short‑circuit hibával.

* **Moderátor jogosultság bekötése**

  * `isAdminProvider` → Firebase Auth **custom claims** (pl. `roles.moderator: true`) alapú provider.
  * Mockolás tesztekhez; fallback fejlesztői környezetben env flaggel.

* **Server‑side votesCount aggregáció (Cloud Functions)**

  * `onCreate` / `onDelete` a `votes/{postId_userId}` alatt → atomikus inkrement/dekrement `posts/{postId}.votesCount` mezőn.
  * Idempotencia és concurrent biztonság: tranzakció vagy FieldValue.increment.
  * Hibatűrés és idempotens retry (Functions retriable errors kezelése).

* **UI/UX finomítások**

  * Lockolt szál komponáló sáv tiltása + egyértelmű banner.
  * Idézetelt poszt (quoted) jelölése kártyával, görgetés az idézett elemhez.
  * `edited` flag megjelenítése (ha `editedAt` nem null).

* **CI/Rules/Index**

  * Rules egységesítés a fenti módosítások után.
  * Szükséges összetett indexek (threads: type/fixtureId/updatedAt, votes by postId) ellenőrzése.

---

🧪 **Tesztállapot**

* **Unit/Widget**

  * Post törlés gomb **nem jelenik meg** nem‑moderátornak.
  * Moderátor menü csak moderátornak látszik (pin/lock).
  * Komponáló tiltása lockolt szálnál.
* **Integration/E2E**

  * **Új**: `forum_e2e_test.dart` – auth → új szál → komment → upvote (votesCount++) → report → lock/pin → UI állapotok ellenőrzése → unlock/unpin → törlés csak moderátornak.
* **Functions & Rules**

  * Jest: create/delete vote → `votesCount` pontosan változik, versenyhelyzetben is.
  * Rules‑unit‑testing: tulaj nem törölhet, moderátor törölhet, lockolt szálba nem írható.

**Pipálható checklista**

* [x] P0: törlés UI elrejtése nem‑moderátornál + repo guard
* [ ] Moderátor claim provider bekötése (custom claims)
* [ ] Functions: votesCount inkrement/dekrement, tesztekkel
* [ ] E2E: teljes happy‑path + lock/pin forgatókönyv
* [ ] Rules és indexek frissítése
* [ ] UX: idézet kártya + edited jelölés

---

🌍 **Lokalizáció**

* Új kulcsok: `moderator_menu_title`, `pin_thread`, `unpin_thread`, `lock_thread`, `unlock_thread`, `moderator_action_success`, `moderator_action_failed`, `thread_locked_banner`, `edited_label` (HU/EN/DE).
* Validációs üzenetek a `fixtureId` és hálózati hibák esetén.

---

📎 **Kapcsolódások**

* **Auth**: Firebase Auth + custom claims (moderator).
* **Firestore**: rules és index frissítés a törlés/lock/pin viselkedéshez.
* **Cloud Functions**: votesCount aggregáció.
* **API‑Football**: érintetlen; csak hibatűrés/validáció a `NewThreadScreen`‑ben.

---

## Hivatkozások (forrás a repo‑ból)

* `canvases/screens/forum_module_moderator_and_aggregation.md`
* `codex/goals/screens/fill_canvas_forum_module_moderator_and_aggregation.yam`

> **Megjegyzés:** Ez a vászon a fenti fájlok „fixup” / kiegészített változata a P0 és P1 teendők lezárásához.
