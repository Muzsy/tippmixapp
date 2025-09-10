-- Badges table for users (earned badges)
create table if not exists public.badges (
  user_id uuid not null,
  key text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, key)
);

alter table public.badges enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='badges' and policyname='badges_read_owner') then
    create policy badges_read_owner on public.badges for select to authenticated using (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='badges' and policyname='badges_insert_owner') then
    create policy badges_insert_owner on public.badges for insert to authenticated with check (user_id = auth.uid());
  end if;
end $$;

