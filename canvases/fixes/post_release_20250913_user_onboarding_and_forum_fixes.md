# 🧩 Post‑release fixcsomag – user onboarding, TippCoin, avatar, fórum és téma

## 🎯 Funkció

A most észlelt hibák egy menetben történő javítása Supabase‑en és a kliensben:

* TippCoin ledger írás (daily bonus + általános coin tranzakció) ne hibázzon, egyenleg frissüljön.
* Regisztráció után legyen `profiles` rekord → FK hibák (tickets/forum) megszűnnek.
* Avatar feltöltés működjön (helyes storage útvonal + RLS policy).
* Fórum „Új szál” és „Szelvény készítése” képernyők ne fussanak RenderFlex overflow‑ba billentyűzetnél.
* Bejelentkezésnél ne fusson „Bad state: ref after dispose”.
* A téma‑választó csak a **zöld** és **pink** sémákat kínálja, az app ezek egyikével induljon (zöld).

## 🧠 Fejlesztési részletek

### 1) TippCoin ledger és daily bonus

**Ok:** a `coins_ledger` táblában kötelező a `type` és a `balance_after`. Az Edge függvények `reason` mezőre írnak, a `balance_after` nincs számolva.

**Megoldás:**

* Új trigger, ami beszúráskor kiszámolja a `balance_after` értéket.
* Edge függvényekben `reason` → `type`. Semmi más logika nem változik.

**Új fájl:** `supabase/migrations/20250913_coins_ledger_balance_trigger.sql`

```sql
create or replace function public.fn_coins_ledger_set_balance_after()
returns trigger as $$
declare v_prev int; begin
  select coalesce(sum(delta),0) into v_prev from public.coins_ledger where user_id=new.user_id;
  new.balance_after := v_prev + new.delta;
  return new; end; $$ language plpgsql;

drop trigger if exists trg_coins_ledger_balance on public.coins_ledger;
create trigger trg_coins_ledger_balance
before insert on public.coins_ledger
for each row execute function public.fn_coins_ledger_set_balance_after();
```

**Diff – `supabase/functions/claim_daily_bonus/index.ts`**

```diff
@@
-    const { error: insErr } = await admin.from("coins_ledger").insert({
-      user_id: uid,
-      delta: 10,
-      reason: "daily_bonus",
-      meta: { source: "edge_function" },
-    });
+    const { error: insErr } = await admin.from("coins_ledger").insert({
+      user_id: uid,
+      delta: 10,
+      type: "daily_bonus",
+      meta: { source: "edge_function" },
+    });
```

**Diff – `supabase/functions/coin_trx/index.ts`**

```diff
@@
-  try {
-    const { delta, reason, meta } = await req.json();
+  try {
+    const { delta, type, meta } = await req.json();
@@
-    const { error: insErr } = await admin.from("coins_ledger").insert({ user_id: uid, delta, reason, meta });
+    const { error: insErr } = await admin.from("coins_ledger").insert({ user_id: uid, delta, type, meta });
```

### 2) `tickets_user_id_fkey` és fórum mentés

**Ok:** nincs sorod a `public.profiles` táblában, ezért minden FK‑hoz kötött insert (tickets, forum) hibára fut.

**Megoldás:**

* **Biztosítsd**, hogy lefusson a meglévő auto‑provision + backfill migráció: `supabase/migrations/202509120015_profiles_trigger_and_backfill.sql`.
* Kliensen a profil‑upsert ne küldjön `null` nicknevet.

**Diff – `lib/services/auth_service_supabase.dart` (`_ensureProfile`)**

```diff
@@
-      await _c.from('profiles').upsert({
-        'id': u.id,
-        'nickname': (u.displayName.isEmpty ? null : u.displayName),
-      }, onConflict: 'id');
+      final fallback = (u.displayName.isNotEmpty)
+          ? u.displayName
+          : (u.email?.isNotEmpty == true ? u.email!.split('@').first : 'user_${u.id.substring(0,8)}');
+      await _c.from('profiles').upsert({
+        'id': u.id,
+        'nickname': fallback,
+      }, onConflict: 'id');
```

### 3) Avatar feltöltés

**Ok:** a kliens path‑ja `avatars/<uid>/...`, Supabase SDK‑ban a bucket **külön** paraméter, az `objects.name` csak a belső útvonal. A meglévő RLS policy is a hibás névsémát várja.

**Megoldás:**

* Kliensen path: `'$uid/avatar_256.png'`.
* Új migráció: töröljük és újra létrehozzuk az `avatars` policy‑ket a helyes ellenőrzéssel.

**Diff – `lib/services/profile_service.dart`**

```diff
@@
-    final path = 'avatars/$uid/avatar_256.png';
+    final path = '$uid/avatar_256.png';
```

**Új fájl:** `supabase/migrations/20250913_storage_avatars_policies_fix.sql`

```sql
-- Replace buggy policies that expected 'avatars/<uid>/...' in name
 drop policy if exists "avatars insert own" on storage.objects;
 drop policy if exists "avatars update own" on storage.objects;
 drop policy if exists "avatars delete own" on storage.objects;
 drop policy if exists "avatars read own"   on storage.objects;

 create policy "avatars insert own"
   on storage.objects for insert to authenticated
   with check (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

 create policy "avatars update own"
   on storage.objects for update to authenticated
   using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text)
   with check (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

 create policy "avatars delete own"
   on storage.objects for delete to authenticated
   using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

 create policy "avatars read own"
   on storage.objects for select to authenticated
   using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);
```

### 4) RenderFlex overflow – Fórum „Új szál” & Szelvény

**Megoldás:** görgethető űrlap + alsó padding a billentyűzethez.

**Diff – `lib/screens/forum/new_thread_screen.dart`**

```diff
@@
-    return Scaffold(
-      appBar: AppBar(title: Text(loc.new_thread_title)),
-      body: Padding(
-        padding: const EdgeInsets.all(16),
-        child: Form(
+    return Scaffold(
+      appBar: AppBar(title: Text(loc.new_thread_title)),
+      body: LayoutBuilder(builder: (context, _) {
+        final inset = MediaQuery.of(context).viewInsets.bottom;
+        return SingleChildScrollView(
+          padding: EdgeInsets.fromLTRB(16,16,16,16+inset),
+          child: Form(
@@
-            children: [
+            children: [
               // (mezők változatlanok)
@@
-          ),
-        ),
-      ),
-    );
+          ),
+        );
+      }),
+    );
```

**Diff – `lib/screens/create_ticket_screen.dart`**

```diff
@@
-  return Scaffold(
-    appBar: AppBar(title: Text(loc.createTicketTitle)),
-    body: Padding(
+  return Scaffold(
+    resizeToAvoidBottomInset: true,
+    appBar: AppBar(title: Text(loc.createTicketTitle)),
+    body: LayoutBuilder(builder: (context, _) {
+      final inset = MediaQuery.of(context).viewInsets.bottom;
+      return SingleChildScrollView(
+        padding: EdgeInsets.fromLTRB(16,16,16,16+inset),
-        child: Column(
+        child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             // (lista + stake + gomb változatlan)
           ],
-        ),
-      ),
-    ),
+        ),
+      );
+    }),
   );
```

### 5) Login – `ref` használat dispose után

**Diff – `lib/screens/auth/login_form.dart`**

```diff
@@
-    final error = await ref
+    final error = await ref
         .read(authProvider.notifier)
         .login(_emailCtrl.text, _passCtrl.text);
-    if (error == null) {
+    if (!mounted) return;
+    if (error == null) {
       await ref.read(analyticsServiceProvider).logLoginSuccess(widget.variant);
     }
```

### 6) Téma – csak zöld/pink, stabil induló séma

**Diff – `lib/main.dart`**

```diff
@@
-            buildTheme(
-              scheme: FlexScheme.values[theme.schemeIndex],
+            buildTheme(
+              scheme: availableThemes[theme.schemeIndex],
               brightness: Brightness.light,
             );
@@
-            buildTheme(
-              scheme: FlexScheme.values[theme.schemeIndex],
+            buildTheme(
+              scheme: availableThemes[theme.schemeIndex],
               brightness: Brightness.dark,
             );
```

**Diff – `lib/services/theme_service.dart`**

```diff
@@
-  void toggleTheme() {
-    final next = (state.schemeIndex + 1) % FlexScheme.values.length;
+  void toggleTheme() {
+    final next = (state.schemeIndex + 1) % availableThemes.length;
     state = state.copyWith(schemeIndex: next);
     // ...
   }
@@
-  void setScheme(int index) {
-    if (index >= 0 && index < FlexScheme.values.length) {
+  void setScheme(int index) {
+    if (index >= 0 && index < availableThemes.length) {
       state = state.copyWith(schemeIndex: index);
       // ...
     }
   }
```

## 🧪 Tesztállapot

* Unit: `test/services/coin_service_test.dart`, `test/services/coin_balance_validation_test.dart` – napi bónusz és ledger insert ellenőrzés.
* Widget: `test/widgets/profile_header_coin_badge_test.dart`, `test/widgets/new_thread_screen_test.dart`, `test/screens/create_ticket_screen_test.dart` – scroll/overflow regresszió ellenőrzés (billentyűzet emulációval), avatar URL beállás.
* Integráció: `test/integration/theme_live_switch_test.dart` – téma váltás csak a két elérhető séma között.

## 🌍 Lokalizáció

* Nincs nyelvi kulcs változás. Hibaüzenetek a meglévő `AppLocalizations` kulcsokat használják.

## 📎 Kapcsolódások

* Supabase: `coins_ledger`, `profiles`, `storage.objects (avatars bucket)`, `user_settings`.
* Edge Functions: `claim_daily_bonus`, `coin_trx`.
* Flutter modulok: auth/profile/coin/forum/tickets/theme.

---

**Telepítési sorrend:** 1) futtasd az új migrációkat; 2) Edge functions deploy; 3) kliens build; 4) smoke test forgatókönyv (reg → daily bonus → avatar → új szál → szelvény → téma váltás).
