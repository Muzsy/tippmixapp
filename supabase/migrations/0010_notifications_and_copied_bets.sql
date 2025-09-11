-- Notifications and Copied Bets tables with RLS (owner-only)

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  title text not null,
  description text default '',
  timestamp timestamptz not null default now(),
  is_read boolean not null default false,
  category text default 'system',
  archived boolean not null default false,
  preview_url text,
  destination text
);

alter table public.notifications enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='notifications' and policyname='notifications_select_owner') then
    create policy notifications_select_owner on public.notifications for select to authenticated using (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='notifications' and policyname='notifications_update_owner') then
    create policy notifications_update_owner on public.notifications for update to authenticated using (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='notifications' and policyname='notifications_insert_authenticated') then
    create policy notifications_insert_authenticated on public.notifications for insert to authenticated with check (user_id = auth.uid());
  end if;
end $$;

create index if not exists idx_notifications_user_time on public.notifications(user_id, timestamp desc);

-- Copied bets table to store edited copies before submission
create table if not exists public.copied_bets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  tips jsonb not null default '[]'::jsonb,
  was_modified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.copied_bets enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='copied_bets' and policyname='copied_bets_owner_select') then
    create policy copied_bets_owner_select on public.copied_bets for select to authenticated using (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='copied_bets' and policyname='copied_bets_owner_insert') then
    create policy copied_bets_owner_insert on public.copied_bets for insert to authenticated with check (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='copied_bets' and policyname='copied_bets_owner_update') then
    create policy copied_bets_owner_update on public.copied_bets for update to authenticated using (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='copied_bets' and policyname='copied_bets_owner_delete') then
    create policy copied_bets_owner_delete on public.copied_bets for delete to authenticated using (user_id = auth.uid());
  end if;
end $$;

create index if not exists idx_copied_bets_user_time on public.copied_bets(user_id, created_at desc);
