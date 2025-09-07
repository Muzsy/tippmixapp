# Fórum modul – teljes MVP+ terv (Canvas + Codex YAML)

> **Cél**: A Fórum modul teljes (MVP+) megvalósításának részletes, végrehajtható terve a TippmixApp projekten belül. A dokumentum két részből áll: 1) Canvas (funkció, fejlesztési részletek, tesztek, lokalizáció, kapcsolatok), 2) Codex YAML (lépésről lépésre, végrehajtható feladatlista a Codex IDE számára).

---

## 🎯 Funkció

**Felhasználói cél**: A közösségi tippeléshez kapcsolódó beszélgetések, kérdések, statisztikák és élő meccs-szálak kezelése. A felhasználók meccsekhez kötött és általános témaszálakat hozhatnak létre, posztolhatnak, szavazhatnak, jelenthetnek, valamint értesítést kaphatnak a követett szálakról.

**Scope (MVP+)**

* **Szálak (Threads)**: létrehozás, listázás, rendezés (legújabb/legaktívabb), szűrés (meccshez kötött `fixtureId`, típus), lezárt szál kezelése.
* **Posztok (Posts)**: írás, válasz, idézet, szerkesztés (időablak), törlés (saját), képméretű szöveg formázás egyszerű (pl. új sor, kódblokk jelölő), link autófelismerés.
* **Szavazás (Votes/Likes)**: egyszeres upvote per user, aggregált számláló; duplikáció védelme.
* **Jelentés (Reports)**: spam/sértő jelzés admin felé; kliensoldali űrlap ok-listával.
* **Moderáció (Light)**: szál zárolása (admin), poszt elrejtése (admin jelölés), pinned/kiemelt szál.
* **Követés/értesítés (Follow/Notify)**: szál követése, új poszt értesítés (először kliensoldali jelzés és „új” badge; push később).
* **Meccs-integráció**: API-Football-ból származó mérkőzés adatok megjelenítése a szál fejlécében (idő, csapatok, állás, odds-pillanatkép – ha elérhető).
* **Állapotkezelés**: reaktív adatfolyamok (threads/posts), lapozás, üres/hiba állapotok, visszajelzések.
* **Biztonság**: Firestore Security Rules (auth-kötelező, tulajdonvédelem, mező whitelisting, limitek), szükséges indexek.
* **Tesztelés**: unit + widget + rules + (opcionális) integrációs teszt Firestore emulátorral.

**Nem cél most (későbbi ütem)**

* Szerveroldali tartalomszűrés (AI/CF), komplex rangsorolás, bővített rich-text editor, médiafeltöltés, teljes értékű push értesítések, admin felület.

---

## 🧠 Fejlesztési részletek

### Adatmodell (Firestore)

* **Gyűjtemények**

  * `threads`: `{ id, fixtureId (opcionális), type: [general, match, system], title, createdAt, createdBy, locked, pinned, lastActivityAt, postsCount, votesCount }`
  * `threads/{threadId}/posts`: `{ id, threadId, userId, type: [tip, comment, system], content, quotedPostId?, createdAt, editedAt?, votesCount, isHidden? }`
  * `votes`: `{ id, entityType: [post], entityId, userId, createdAt }` (lehet subcollection is, de egyszerű MVP-hez külön gyűjtemény is elfogadható)
  * `reports`: `{ id, entityType: [post, thread], entityId, reason, message?, reporterId, createdAt, status: [open,resolved] }`
  * `user_forum_prefs`: `{ userId, followedThreadIds[], lastReads: { threadId: timestamp } }` (opcionális, később)

* **Index javaslatok (példa)**

  * `threads`: `(fixtureId ASC, type ASC, pinned DESC, locked ASC, lastActivityAt DESC)`, `(type ASC, lastActivityAt DESC)`, `(createdBy ASC, createdAt DESC)`
  * `posts`: `(threadId ASC, createdAt DESC)`
  * `votes`: `(entityType ASC, entityId ASC, createdAt DESC, userId ASC)`
  * `reports`: `(status ASC, createdAt DESC)`

* **Következetes idő**: `createdAt/editedAt/lastActivityAt` mindig `FieldValue.serverTimestamp()` (írás után olvasásban validálni).

### Security Rules (vázlat)

* **Általános**: csak `request.auth != null` írhat bárhová.
* **Threads**:

  * `create`: bejelentkezett user, kötelező mezők (`title`, `type`, `createdBy == request.auth.uid`, `createdAt` szerveridő), tilos kliensnek `postsCount`, `votesCount`, `lastActivityAt` beállítása.
  * `update`: csak admin zárolhat/pinnelhet; creator szerkesztheti a `title`-t korlátozott időablakban (pl. 10 perc); tilos számlálókat módosítani.
  * `read`: nyilvános, vagy ha később privát lesz, akkor jogosultság szerinti.
* **Posts**:

  * `create`: bejelentkezett user; kötelező mezők (`threadId`, `content`, `userId == auth.uid`), `createdAt` szerveridő; ha `thread.locked==true`, akkor tiltás.
  * `update`: szerkesztés időablakban (pl. 10 perc) és csak `content`/`editedAt` változhat.
  * `delete`: saját poszt törlése időablakon belül, vagy admin.
  * `read`: ha `isHidden==true`, akkor csak admin/creator olvashatja.
* **Votes**:

  * `create`: egy user egy post-ra csak egyszer (rules szinten nehéz 100%-ra garantálni; kliens+felhőoldali aggregáció segíthet). Tilos nem a saját `userId`-val írni.
  * `delete`: saját vote törölhető (unvote).
* **Reports**:

  * `create`: bármely bejelentkezett; `status` írás tiltott; `reporterId == auth.uid` kötelező.
  * `update`: csak admin állíthat `status`-t.

> **Megjegyzés**: A fenti logikát végig kell futtatni a rules unit teszteken (Rules Unit Testing keretrendszerrel), és adott esetben kisebb kompromisszumokkal (pl. edit időablak nélkül első körben), ha az index/rules komplexitás túl magas.

### UI képernyők és fő flow-k

1. **ForumScreen**

   * Tab/segédszűrők: *All*, *Matches*, *General*, *Pinned*.
   * Rendezés: *Latest activity*, *Newest*.
   * Szál kártya: cím, típus badge, utolsó aktivitás, posztok száma, pinned/locked jelölés, opcionális meccs infó.
   * Üres állapot és hibaállapot üzenetek.
   * FAB: új szál létrehozása.

2. **NewThreadScreen / Composer (bottom-sheet is lehet)**

   * Mezők: cím (kötelező), típus, opcionális `fixtureId`, első poszt tartalma.
   * Validáció: min/max hossz, tiltott szavak kliensszinten (soft), karakter számláló.
   * Mentés: szál + első poszt tranzakciója (vagy soros írás és hiba esetén visszajelzés).

3. **ThreadViewScreen**

   * Fejléc: szál adatai + meccs komponens (ha van `fixtureId`).
   * Posztlista: fordított időrend (legújabb felül vagy alul – termékdöntés; default: legrégebbi felül, alul új komponens). Lapozás (limit/`startAfter`).
   * Műveletek: válasz, idézet (idézett blokk megjelenítése), szerkesztés (időablak), törlés (időablak), jelentés, szavazás (like/upvote). Locked állapotban composer letiltva.
   * Követés: „Követem” / „Követem ne” kapcsoló, badge az új posztokhoz (kliens memóriában vagy `user_forum_prefs` alapon később).

4. **Moderációs elemek (UI)**

   * Admin jelvény a moderátornál.
   * Pinned/Locked toggle csak adminnak (rejtett menüben).

### State & adat-hozzáférés

* **Repository** réteg biztosítja: threads stream, posts stream, create/update/delete, vote/report.
* **Provider/Notifier** (pl. Riverpod):

  * `ForumFilterState`, `ThreadListController`, `ThreadDetailController`, `ComposerController`.
  * Hibatűrés: retry, progress jelzések, idempotens gombok (dupla kattintás védelem).

### Navigáció

* Útvonalak: `/forum`, `/forum/new`, `/forum/:threadId`.
* Alsó nav: Fórum ikon és címkulcs (HU/EN/DE), jelvény a követett szálak új posztja esetén (később).

### Nem funkcionális követelmények

* **Teljesítmény**: lapozás 20–30-as tételekkel; indexelt lekérdezések; minimal rebuild a listákon.
* **Hibatűrés**: offline cache (ha projektben van beállítva), konfliktusok kezelése (edit/törlésnél).
* **Naplózás**: analitika események (szál létrehozás, poszt létrehozás, vote, report).
* **Hozzáférhetőség**: fókuszkezelés, nagyobb betűméret támogatása, kontrasztok.

---

## 🧪 Tesztállapot

**Unit tesztek**

* Modellek (to/from JSON, egyenlőség, kötelező mezők).
* Repository (threads/posts lekérdezés, mentés, hibaforgatókönyvek mockolt Firestore klienssel).

**Widget tesztek**

* ForumScreen: üres állapot, lista render, rendezés/szűrés interakciók.
* ThreadViewScreen: posztlista render, composer tiltás locked állapotban, vote/report gombok megjelenése.
* NewThread/Composer: validációk, mentés gomb engedélyezése/tiltása, hiba visszajelzés.

**Security Rules tesztek**

* Auth nélküli írás tiltása minden gyűjteményre.
* Saját poszt szerkesztése/törlése csak időablakban.
* Locked thread → új poszt tiltás.
* Votes: idegen `userId`-val írás tiltás.
* Reports: `status` kliensoldali írás tiltása.

**Integrációs teszt (Emulátor)** *(opcionális, javasolt)*

* Emulátoron: szál létrehozás → első poszt létrehozás → szál listában megjelenik → posztlista render.
* Vote lifecycle (vote, unvote), Report létrehozás.
* Index hibák detektálása (ha query indexet igényel, a teszt jelezze és adjon útmutatót az index hozzáadáshoz).

**CI**

* Fut: unit + widget + rules tesztek. Integrációs teszt külön job/flag mögé tehető emulátorral.

---

## 🌍 Lokalizáció

* **Kulcsok**:

  * Navigáció: `nav_forum`.
  * ForumScreen: `forum_title`, `filter_all`, `filter_matches`, `filter_general`, `sort_latest`, `sort_newest`, `empty_forum`, `error_forum`.
  * Thread: `thread_pinned`, `thread_locked`, `thread_follow`, `thread_unfollow`, `new_posts_badge`.
  * Composer: `new_thread_title`, `thread_type`, `thread_type_match`, `thread_type_general`, `thread_type_system`, `fixture_id_optional`, `first_post_placeholder`, `btn_create_thread`, `btn_post`, `validation_required`, `validation_length`, `saved_success`, `saved_error`.
  * Post műveletek: `reply`, `quote`, `edit`, `delete`, `report`, `like`, `unlike`, `confirm_delete`.
  * Jelentés: `report_reason_spam`, `report_reason_offensive`, `report_reason_other`, `report_message_optional`, `report_submitted`.
* **Nyelvek**: HU/EN/DE mindháromra fordítás.
* **Formátumok**: dátum/idő lokális, számformátum lokális.

---

## 📎 Kapcsolódások

* **API-Football**: meccs meta (csapatok, kezdési idő, állás) megjelenítése a ThreadView fejlécben.
* **Auth modul**: kötelező bejelentkezés íráshoz; avatar/név megjelenítése poszt mellett.
* **TippCoin/Badge** *(későbbi)*: aktivitás után jelvény/coin jutalmazás (külön ütem).
* **Értesítések** *(későbbi)*: push integráció, ha a projektben elérhető.