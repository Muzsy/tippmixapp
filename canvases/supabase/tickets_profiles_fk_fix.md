# Tickets – FK hiba javítása (profiles hiány) – migrációs vászon

🎯 **Funkció**

* A "Fogadás leadása" gomb megnyomásakor jelentkező **FK hiba** megszüntetése: `tickets.user_id → profiles.id` hivatkozás sérül, mert a felhasználóhoz **nincs profil rekord** a `profiles` táblában.
* Megoldás: **automatikus profile‑létrehozás** az Auth új felhasználóira + **egyszeri backfill** a hiányzó profilokra, és opcionális app‑oldali `ensureProfile()` hívás a stabilitásért.

🧠 **Fejlesztési részletek**
**Hiba forrása:**

* Supabase RDBMS rétegben a `tickets.user_id` FK `profiles(id)`‑re mutat. Új (vagy migrált) usernél a `profiles` rekord nem jön létre, ezért a `INSERT INTO tickets (...) VALUES (..., user_id=...)` **23503** hibával megáll.

**Megoldási stratégia (DB‑oldal a biztos):**

1. **DB trigger**: `auth.users` INSERT → `public.profiles` beszúrás ugyanazzal az `id`‑val. (Standard Supabase minta.)
2. **Backfill**: egyszeri SQL, ami minden létező `auth.users` userhez létrehozza a hiányzó `profiles` rekordot.
3. **RLS/policy ellenőrzés**: a `profiles` és `tickets` táblán legyenek meg a minimum szükséges RLS szabályok (self‑access, insert saját user\_id‑val, stb.).
4. **(Opcionális) App‑oldali guard**: első sikeres auth után `ensureProfile(currentUser)` (idempotens `upsert`) – védőháló lokalizált fejlesztéskor is.

**Változtatások (repo):**

* **SQL migráció** új fájlban (supabase):

  * `supabase/migrations/xxxxxx_profiles_trigger_and_backfill.sql`
  * Tartalma: trigger function + trigger + backfill + (opcionális) RLS policy pótlások.
* **Alkalmazás kód** (opcionális, de ajánlott):

  * `ensureProfile()` hívás bevezetése az auth belépési pontján (pl. első sign‑in / app start session restore után). Idempotens `insert ... on conflict (id) do update set ...`.
* **Dokumentáció**: rövid megjegyzés a hiba okáról és a migrációról.

**Minták (SQL – lényegi részletek):**

```sql
-- 1) Trigger function: új auth.users esetén auto-profil
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;$$ language plpgsql security definer;

-- 2) Trigger az auth.users táblán
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3) Backfill a meglévő userekre
insert into public.profiles (id, email)
select u.id, u.email
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- 4) (Opcionális) RLS minták (ha hiányoznak)
-- enable row level security
alter table public.profiles enable row level security;
alter table public.tickets  enable row level security;

-- csak saját profil olvasása/szerkesztése
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- ticket insert: csak saját user_id‑val
create policy "tickets_insert_own" on public.tickets
  for insert with check (user_id = auth.uid());
-- ticket select: saját és/vagy publikus logika – projektszabályok szerint
create policy "tickets_select_own" on public.tickets
  for select using (user_id = auth.uid());
```

> Megjegyzés: a fenti RLS szekció csak akkor fusson, ha még **nincs** ilyen policy – a migrációs fájl ezt IF NOT EXISTS‑szel vagy guard checkkel kezelje.

🧪 **Tesztállapot**

* **DB**: futtasd lokálisan `supabase start` környezetben a migrációt; `auth.users`‑be beszúrás → profil auto‑létrejön; `tickets` insert saját `auth.uid()`‑dal sikeres.
* **App**: belépés után (akár vendégből friss regisztrációval) egy fogadás mentése már nem dob FK hibát.

🌍 **Lokalizáció**

* Nincs új UI szöveg (kivéve, ha app‑oldali hibaüzenetet finomítunk). Ha mégis, HU/EN kulcs: `ticket_submit_fk_error_fixed_note` (opcionális).

📎 **Kapcsolódások**

* Auth modul: profil‑upsert hívás (opcionális guard)
* Tickets modul: `insert` use‑case
* Supabase: `auth.users`, `public.profiles`, `public.tickets` táblák, RLS/policy

---

## Pipálható checklist (P0 → P2)

**P0 – Kötelező**

* [ ] SQL migráció létrehozva (trigger + backfill)
* [ ] FK hiba reprodukció után megszűnt (lokális környezetben teszt)

**P1 – Ajánlott**

* [ ] RLS policyk ellenőrizve és pótolva, ha hiányoznak
* [ ] App‑oldali `ensureProfile()` hívás a belépésnél (idempotens)

**P2 – Opcionális**

* [ ] Rövid doksi a `docs/` vagy `README` kiegészítésben a miértekről
* [ ] Minimális integrációs teszt a tickets mentéshez (mockolt auth.uid())
