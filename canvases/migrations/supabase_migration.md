# supabase\_migration.md — FRISSÍTETT VÁLTOZAT (2025-09-10)

> **Keret**: nincs éles adat (0 felhasználó / 0 szelvény). Firebase → Supabase csere: Auth, DB (Firestore→Postgres), Realtime, Storage, Functions (Cloud Functions→Edge Functions), Cron. **FCM** marad push-ra. **Cél**: Free/Pro Supabase kereten belül maradó, olcsó, egyszerűen üzemeltethető backend.

---

## ✅ Készültségi állapot — ami **már kész**

* [x] Supabase fiók létrehozva.
* [x] Projekt létrehozva **tipsterino** néven.
* [x] `SUPABASE_URL` és `SUPABASE_ANON_KEY` bemásolva a helyi `.env`-be.
* [x] Supabase CLI telepítve és `supabase login` lefuttatva.
* [x] `supabase init` és `supabase start` lefutott lokálisan.
* [x] Auth mód: **email/jelszó + email megerősítés** a Supabase felületén beállítva.

> Következmény: a további teendők **kizárólag** a kódoldali migrációra, az adatbázis-sémára, RLS-re, Edge Functions-re, CRON-ra és a CI/CD-re fókuszálnak. A manuális előkészítés kipipálva.

---

## 🎯 Funkció

**Mit érünk el az átállással?**

* Firebase költségcsapdák eliminálása (Logging ingest, Functions GB-sec). Supabase: invokációs kvóták, fix keretek.
* Relációs modell (Postgres + RLS) a Firestore helyett: tiszta séma a fórum/szelvény/coin ledger modulokra.
* Cloud Functions portolása **Edge Functions**-re; időzítések **Supabase Cron**-nal.
* Storage: Supabase Storage + aláírt URL-ek (profilképek, mellékletek).
* Auth: Supabase Auth (email + opcionális OAuth). Google/Facebook később visszaköthető.
* Realtime: táblaszintű csatornák (fórum thread/post élő frissítés).

**Nem változik / marad**

* **FCM** push értesítések (Android/iOS).
* UI/UX és lokalizáció (HU/EN/DE) – csak a backend-hívások cserélődnek.

---

## 🧠 Fejlesztési részletek

### Érintett fő komponensek és fájlok

* **Init & konfiguráció**: `lib/bootstrap.dart`, `.env.settings.*` → Supabase init, Firebase init kivezetése.
* **Auth**: `lib/services/auth_service.dart`, `lib/controllers/splash_controller.dart`, `lib/screens/register_*` → `supabase_flutter.auth` API-k (email+jelszó, magic link opcionális később).
* **Firestore réteg** → PostgREST:

  * Fórum: `lib/features/forum/data/firestore_forum_repository.dart` → **új** `lib/features/forum/data/supabase_forum_repository.dart` (PostgREST + Realtime).
  * Szelvény: `lib/services/bet_slip_service.dart`, `lib/services/ticket_service.dart` → PostgREST táblák (`tickets`, `ticket_items`).
  * Profil/statisztika: `lib/services/profile_service.dart`, `lib/services/stats_service.dart`.
* **Functions hívások**: `lib/services/{coin_service,finalizer_service,reward_service}.dart` → Edge Functions HTTP.
* **Storage**: `lib/services/storage_service.dart` → Supabase Storage (bucket: `avatars`).
* **Remote Config / Analytics / App Check**: `lib/services/experiment_service.dart`, `lib/services/analytics_service.dart`, `lib/services/recaptcha_service.dart` → RC kivezetés, Plausible/PostHog opció, Turnstile (opcionális).
* **Cloud Functions (portolandó)** – forrás: `cloud_functions/src/`:

  * `bonus_claim.ts`, `daily_bonus.ts`, `username_reservation.ts`
  * `finalize_publish.ts`, `force_finalizer.ts`, `match_finalizer.ts`
  * `tickets/payout.ts`, `triggers/forumVotes.ts` (→ DB trigger / materializált számláló)
  * közös logika: `coin_trx.logic.ts`

### Cél Postgres-séma (minimál)

* `profiles(id uuid PK, nickname text unique, avatar_url text, created_at timestamptz)`
* `forum_threads(id uuid PK, title text, author uuid FK, created_at)`
* `forum_posts(id uuid PK, thread_id uuid FK, author uuid FK, body text, votes_count int default 0, created_at)`
* `votes(post_id uuid FK, user_id uuid FK, PRIMARY KEY(post_id,user_id))`
* `tickets(id uuid PK, user_id uuid FK, status text, created_at)`
* `ticket_items(id uuid PK, ticket_id uuid FK, fixture_id text, market text, odd numeric, selection text)`
* `coins_ledger(id uuid PK, user_id uuid FK, type text, delta int, balance_after int, ref_id uuid, created_at)`

**RLS minták**

* `profiles`: a user csak a saját rekordját írhatja, mindenki olvashat (nickname ellenőrzéshez).
* `forum_*`: olvasás publikus; írás csak bejelentkezett usernek; moderátor role külön policy.
* `tickets`, `ticket_items`, `coins_ledger`: csak tulaj olvashat/írhat (ledger: írás csak szerver/edge role).

**Realtime**

* Csatornák: `forum_posts` (filter: `thread_id = :id`), `tickets` státusz.
* Figyelj a **peak concurrent** értékre (Free: 200, Pro: 500).

**CRON / ütemezés**

* `match_finalizer`, `tickets/payout` → Edge Function + **Supabase Cron** (pg\_cron) időzített HTTP hívással.
* Egyszerű szabály: 5–10 perc; spike esetén batch.

**Storage**

* Bucket: `avatars`. Írás: bejelentkezett user → `avatars/{user_id}/...`. Olvasás: signed URL.

**CI/CD**

* GitHub Actions: `supabase db push` (migrációk), `supabase functions deploy <name>`.
* Secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.

### Pipálható feladatlista (kódoldali, **maradék**)

* [ ] Firebase package-ek eltávolítása; `supabase_flutter` hozzáadása.
* [ ] `bootstrap.dart`: Supabase init, Firebase init eltávolítása.
* [ ] Auth réteg csere (email+jelszó), `profiles` tábla seed + profilbetöltés.
* [x] Fórum repo átírása PostgREST-re + Realtime.
* [x] Szelvény/ticket service átírása PostgREST-re, normalizált táblákra.
* [x] Storage: `avatars` bucket, feltöltés + signed URL.
* [x] Edge Functions: `coin_trx`, `claim_daily_bonus`, `reserve_nickname` (HTTP, JWT guard, idempotencia).
* [ ] CRON: `match_finalizer`, `tickets_payout` ütemezése.
* [x] DB trigger: `votes` INSERT/DELETE → `forum_posts.votes_count` frissítés.
* [x] RLS policy-k táblánként, tesztelt példákkal.
* [x] Remote Config kivezetése → `config` tábla / flags.
* [ ] Analytics váltás (Plausible/PostHog) – opcionális.
* [x] CI frissítés: Supabase deploy pipeline, környezeti kulcsok.
* [ ] Eltakarítás: App Check, régi Firebase utils, GCP deploy fájlok.

---

## 🧪 Tesztállapot

**Cél**: minden új réteghez unit/widget/integrációs teszt.

* [ ] Auth: be/ki, email megerősítés flow, token refresh, profil betöltés.
* [ ] Fórum: thread listázás, post létrehozás, vote, Realtime esemény.
* [ ] Tickets: létrehozás, item hozzáadás, státuszváltás (finalizer mock).
* [ ] Coins ledger: szerveroldali idempotens könyvelés (dupla submit = 1 trx).
* [ ] Storage: avatar feltöltés + olvasás signed URL-lel.
* [ ] RLS: negatív tesztek (más user adatát nem látja/írja), moderátor pozitív.
* [ ] Edge Functions: 200/401/403 útvonalak, schema validation.

Futtatás: `flutter analyze`, `flutter test` (unit+widget), Edge Functions: deno test/jest, SQL: psql ellenőrző scriptek.

---

## 🌍 Lokalizáció

* Nyelvi kulcsok változatlanok. Auth/hibaüzenetek frissülnek Supabase szótár szerint (HU/EN/DE). Új kulcsok: „nickname foglalt”, „session lejárt”, „nincs jogosultság (RLS)”.

---

## 📎 Kapcsolódások

* **Minták**: `canvases/screens/forum_module_mvp.md`, `codex/goals/screens/fill_canvas_forum_module_mvp_en_part1.yaml` (stílus/szerkezet referenciaként).
* **Forráskód (érintett tartományok)**:

  * `lib/bootstrap.dart`, `lib/services/*`, `lib/features/forum/**`
  * `cloud_functions/src/**` (portolandó logika)
  * `.github/workflows/**` (CI változás)
* **Doksi**: `/docs`, `/codex_docs` – frissítendő: architekt/infra, routing\_integrity, testing\_guidelines, localization\_logic.

---

### Készültségi definíció

* Minden fenti checkbox kipipálva **és**:

  * `flutter analyze` hibamentes
  * unit+widget tesztek zöldek
  * Edge Functions deployolva, Cron beállítva
  * RLS policy-k negatív/pozitív tesztekkel bizonyítottak
  * CI fut, `main`-re merge után automata deploy

---
