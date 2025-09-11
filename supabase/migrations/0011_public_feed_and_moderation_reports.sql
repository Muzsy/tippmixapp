-- Public feed and moderation reports tables

create table if not exists public.public_feed (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  event_type text not null,
  message text not null,
  timestamp timestamptz not null default now(),
  extra_data jsonb not null default '{}',
  likes text[] not null default '{}'
);

alter table public.public_feed enable row level security;

-- Public read feed, write by authenticated owners
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='public_feed' and policyname='public_feed_read_all') then
    create policy public_feed_read_all on public.public_feed for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='public_feed' and policyname='public_feed_insert_owner') then
    create policy public_feed_insert_owner on public.public_feed for insert to authenticated with check (user_id = auth.uid());
  end if;
end $$;

create index if not exists idx_public_feed_time on public.public_feed(timestamp desc);

-- Moderation reports (owner can insert; reading typically restricted)
create table if not exists public.moderation_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  target_id text not null,
  target_type text not null,
  reason text not null,
  timestamp timestamptz not null default now()
);

alter table public.moderation_reports enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='moderation_reports' and policyname='moderation_reports_insert_owner') then
    create policy moderation_reports_insert_owner on public.moderation_reports for insert to authenticated with check (user_id = auth.uid());
  end if;
end $$;

-- No general SELECT policy to avoid exposing reports; admins/moderators should use elevated role.

