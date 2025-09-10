-- Align forum_threads/forum_posts and tickets schema with app fields

-- forum_threads extras
alter table public.forum_threads
  add column if not exists pinned boolean not null default false,
  add column if not exists locked boolean not null default false,
  add column if not exists last_activity_at timestamptz not null default now(),
  add column if not exists posts_count integer not null default 0,
  add column if not exists votes_count integer not null default 0;

-- forum_posts extras
alter table public.forum_posts
  add column if not exists edited_at timestamptz,
  add column if not exists is_hidden boolean not null default false,
  add column if not exists quoted_post_id uuid references public.forum_posts(id);

-- tickets numeric columns
alter table public.tickets
  add column if not exists stake numeric not null default 0,
  add column if not exists total_odd numeric not null default 1,
  add column if not exists potential_win numeric not null default 0,
  add column if not exists updated_at timestamptz not null default now();

-- reports table used by reportPost()
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.forum_posts(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reason text,
  created_at timestamptz not null default now()
);

alter table public.reports enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='reports' and policyname='reports_read_all') then
    create policy reports_read_all on public.reports for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='reports' and policyname='reports_insert_owner') then
    create policy reports_insert_owner on public.reports for insert to authenticated with check (reporter_id = auth.uid());
  end if;
end $$;

