# 🔧 Post‑release Hotfix 2 – Fórum poszt insert + Szelvény képernyő üres/összeomlik

## 🎯 Funkció

A most feltöltött log (RenderFlex unbounded constraints) alapján:

* A **Szelvény készítése** képernyő üres/összeomlik a `Column` + `Expanded` és görgetős ős kombinációja miatt.
* A **Fórum poszt létrehozás** továbbra sem sikerül – gyanú: RLS/policy rendben, de a hiba elnyelődik; pontos ok naplózása és (ha kell) séma‑/policy korrekció.

## 🧠 Fejlesztési részletek

### 1) Szelvény képernyő – unbounded constraints fix

**Ok:** a log szerint a `Column` (parent: `_SingleChildViewport`) alatt **Expanded** gyerek van → ütközik a szülő zsugorodó magasságával. (lásd `create_ticket_screen.dart:102` környéke.)

**Megoldás:**

* `Column(mainAxisSize: MainAxisSize.min)` + az **Expanded** helyett `Flexible(fit: FlexFit.loose)`.
* A belső `ListView` legyen `shrinkWrap: true`, `physics: NeverScrollableScrollPhysics()` – így a teljes űrlapot a külső görgetés kezeli.

**Diff – `lib/screens/create_ticket_screen.dart` (részlet)**

```diff
@@
-      body: Padding(
+      body: Padding(
         padding: const EdgeInsets.all(16.0),
-        child: Column(
+        child: Column(
+          mainAxisSize: MainAxisSize.min,
           children: [
@@
-            Expanded(
+            Flexible(fit: FlexFit.loose,
               child: tips.isEmpty
                   ? Center(child: Text(loc.no_tips_selected))
                   : ListView.builder(
+                      shrinkWrap: true,
+                      physics: const NeverScrollableScrollPhysics(),
                       itemCount: tips.length,
                       itemBuilder: (context, index) {
                         final tip = tips[index];
                         return Card(
```

**Eredmény:** nincs többé `RenderFlex ... unbounded` kivétel, a lista és az alsó mezők/gombok stabilan jelennek meg.

### 2) Fórum poszt – jobb hiba‑diagnosztika + séma/policy ellenőrzés

**Ok:** a repository elkapja a Supabase hibát, de a UI csak egy általános Snackbart mutat. A valódi hiba (RLS/NOT NULL/FK) rejtve marad.

**Megoldás (kliens):**

* A `SupabaseForumRepository.addThread/addPost` catch ágat egészítsük ki `PostgrestException` kiemeléssel és az üzenet továbbdobásával.
* A `NewThreadScreen` a `state.error` esetén írja ki a konkrét hibaüzenetet is (dev buildben), hogy következő körben pontos okot lássunk.

**Diff – `lib/features/forum/data/supabase_forum_repository.dart` (részlet)**

```diff
@@
-  @override
-  Future<void> addThread(dom.Thread thread) async {
-    await _client.from('forum_threads').insert({
+  @override
+  Future<void> addThread(dom.Thread thread) async {
+    try {
+      await _client.from('forum_threads').insert({
         'id': thread.id,
         'title': thread.title,
         'author': thread.createdBy,
         'created_at': thread.createdAt.toIso8601String(),
         'pinned': thread.pinned,
         'locked': thread.locked,
         'last_activity_at': thread.lastActivityAt.toIso8601String(),
         'type': thread.type.name,
         if (thread.fixtureId != null) 'fixture_id': thread.fixtureId,
-    });
+      });
+    } on PostgrestException catch (e) {
+      throw Exception('Thread insert failed: ${e.message}');
+    }
   }
@@
-    } catch (e) {
-      // Surface better context for UI/error reporting
-      throw Exception('Post insert failed: $e');
+    } on PostgrestException catch (e) {
+      throw Exception('Post insert failed: ${e.message}');
     }
```

**Diff – `lib/screens/forum/new_thread_screen.dart` (hiba megjelenítés)**

```diff
@@
-      error: (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
-        SnackBar(content: Text(loc.saved_error)),
-      ),
+      error: (error, stackTrace) {
+        final msg = error?.toString() ?? loc.saved_error;
+        ScaffoldMessenger.of(context).showSnackBar(
+          SnackBar(content: Text(msg)),
+        );
+      },
```

**Megoldás (séma/policy):** ellenőrző migráció, ami biztosítja az „owner‑insert” policy-k meglétét, és hogy a `fixture_id` **NULL‑ozható** legyen „Általános” típusnál.

**Új SQL – `supabase/migrations/20250913_forum_insert_policies_check.sql`**

```sql
-- forum_threads insert csak saját authorral
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_threads' and policyname='forum_threads_insert_auth') then
    create policy forum_threads_insert_auth on public.forum_threads for insert to authenticated with check (author = auth.uid());
  end if;
end $$;

-- forum_posts insert csak saját authorral
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_posts' and policyname='forum_posts_insert_auth') then
    create policy forum_posts_insert_auth on public.forum_posts for insert to authenticated with check (author = auth.uid());
  end if;
end $$;

-- fixture_id ne legyen kötelező általános threadhez
alter table public.forum_threads alter column fixture_id drop not null;
```

## 🧪 Tesztállapot

* Widget: `create_ticket_screen` – billentyűzet emulációval nincs overflow, lista megjelenik, gomb aktív.
* Fórum: hibás insert mesterséges kiváltása (pl. üres title) – a SnackBar a konkrét Supabase üzenetet is mutatja.

## 🌍 Lokalizáció

* Nincs új kulcs, a hibaüzenet dev‑barát plain text.

## 📎 Kapcsolódások

* Supabase táblák: `forum_threads`, `forum_posts` (RLS/policy), `tickets` (UI fix érinti).

---

**Telepítés:** 1) Kliens diffek be; 2) SQL migráció futtatása; 3) Újra build; 4) Forum poszt próba és szelvény képernyő vizuális ellenőrzés.
