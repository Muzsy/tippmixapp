-- Admin flag on profiles and admin read policies across key tables

-- Add is_admin flag if missing
do $$ begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'profiles' and column_name = 'is_admin'
  ) then
    alter table public.profiles add column is_admin boolean default false;
  end if;
end $$;

-- Helper function to check if current user is admin
create or replace function public.is_current_user_admin()
returns boolean language sql stable as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and coalesce(p.is_admin, false) = true
  );
$$;

-- Admin can select any rows in selected tables (keeps existing owner/public policies intact)
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='profiles' and policyname='profiles_select_admin_all') then
    create policy profiles_select_admin_all on public.profiles for select to authenticated using (public.is_current_user_admin());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='tickets' and policyname='tickets_select_admin_all') then
    create policy tickets_select_admin_all on public.tickets for select to authenticated using (public.is_current_user_admin());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='ticket_items' and policyname='ticket_items_select_admin_all') then
    create policy ticket_items_select_admin_all on public.ticket_items for select to authenticated using (public.is_current_user_admin());
  end if;
end $$;

do $$ begin
  if to_regclass('public.forum_threads') is not null and not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_threads' and policyname='forum_threads_select_admin_all') then
    create policy forum_threads_select_admin_all on public.forum_threads for select to authenticated using (public.is_current_user_admin());
  end if;
end $$;

do $$ begin
  if to_regclass('public.forum_posts') is not null and not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_posts' and policyname='forum_posts_select_admin_all') then
    create policy forum_posts_select_admin_all on public.forum_posts for select to authenticated using (public.is_current_user_admin());
  end if;
end $$;

do $$ begin
  if to_regclass('public.coins_ledger') is not null and not exists (select 1 from pg_policies where schemaname='public' and tablename='coins_ledger' and policyname='coins_ledger_select_admin_all') then
    create policy coins_ledger_select_admin_all on public.coins_ledger for select to authenticated using (public.is_current_user_admin());
  end if;
end $$;

