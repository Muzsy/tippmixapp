# /canvases/forum\_mvp.md

## 🎯 Funkció

A fórum modul **MVP** célja egy meccs‑centrikus, moderálható közösségi felület kiépítése a TippmixApp‑on belül (API‑Football adatokra építve). Fő elemek:

* **Thread lista** (pre/live/post meccsszálak),
* **Thread részletek** nézet: fülek **Tippek • Kommentek • Szavazás**,
* **Composer**: piac/odd kiválasztás az API‑Football snapshotból + indoklás + opcionális TippCoin‑stake,
* **Interakciók**: up/down vote, report, követés,
* **Moderáció**: lockolt thread kezelése, alap abuse‑védelem,
* **Értesítések**: @mention, válasz, követett thread új poszt (FCM).

## 🧠 Fejlesztési részletek

* **Mappa**: `lib/features/forum/` (domain, data, presentation, widgets, providers, services).
* **Adatmodell (Firestore)**: `threads/{threadId}`, `threads/{threadId}/posts/{postId}`, `votes` (sharded), `reports`. Kötelező indexek: posts by threadId (createdAt desc); threads by fixtureId+type (createdAt desc); votes uniq (postId+uid).
* **Életciklus**: CF `fixture_watcher` (pre/live/post thread generálás), CF `event_ingestor` (gól/piros → system poszt).
* **Biztonság**: Firestore Rules v1 (auth‑kötelező írásnál, tulajdonosi frissítés-időablak, mod jogok), minimum input‑validáció.
* **UI/UX**: GoRouter integráció, bottom‑nav‑ba Fórum tab (feature flaggel), skeleton állapotok, üres listák kezelése.
* **Állapotkezelés**: a projektben használt minta automatikus detektálása (provider/riverpod/bloc) és annak megfelelő integráció.
* **API‑Football**: meglévő `ApiFootballService` használata fixture headerhez és odds/market snapshothoz (nem közvetlen call az UI‑ból → cache‑elt adapter a data layerben).

## 🧪 Tesztállapot (elfogadási kritériumok)

* `flutter analyze` hibamentes; **unit+widget+integráció** lefedettség ≥ **80%** a fórum komponensekre.
* Emulator‑teszt: pre/live threadek létrejönnek; posztolás, vote, report működik; lockolt szálon composer rejtett.
* L10n: HU/EN/DE kulcsok lefordítva; `flutter gen-l10n` sikeres.
* Navigáció visszalépésnél állapotmegőrző.
* CI fut: analyze + test + (ha van) functions unit.

## 🌍 Lokalizáció

Új kulcsok (példa): `forum_title`, `forum_empty`, `forum_tab_tips`, `forum_tab_comments`, `forum_tab_poll`, `forum_filter_league`, `forum_filter_fixture`, `composer_hint`, `composer_submit`, `vote_up`, `vote_down`, `report_title`, `report_reason_spam`, `report_reason_offtopic`, `report_reason_abuse`, `thread_locked`, `follow`, `unfollow`.

## 📎 Kapcsolódások

* **API‑Football**: fixture header + odds snapshot a composerhez; delta‑frissítés és cache.
* **TippCoin**: opcionális stake mező az MVP‑ben (elszámolás későbbi lépcső).
* **Profil/Leaderboard**: most teaser/link; aggregálás későbbi lépcső.
* **Értesítések (FCM)**: topic (thread/fixture) feliratkozás + targeted push @mention/reply esetén.
