-- Social features schema: followers & friend_requests

create table if not exists public.followers (
  user_id uuid not null,
  follower_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (user_id, follower_id)
);

alter table public.followers enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='followers' and policyname='followers_read_all') then
    create policy followers_read_all on public.followers for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='followers' and policyname='followers_insert_owner') then
    create policy followers_insert_owner on public.followers for insert to authenticated with check (follower_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='followers' and policyname='followers_delete_owner') then
    create policy followers_delete_owner on public.followers for delete to authenticated using (follower_id = auth.uid());
  end if;
end $$;

create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  to_uid uuid not null,
  from_uid uuid not null,
  accepted boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.friend_requests enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friend_requests' and policyname='friend_requests_read_owner') then
    create policy friend_requests_read_owner on public.friend_requests for select to authenticated using (to_uid = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friend_requests' and policyname='friend_requests_insert_owner') then
    create policy friend_requests_insert_owner on public.friend_requests for insert to authenticated with check (from_uid = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friend_requests' and policyname='friend_requests_update_owner') then
    create policy friend_requests_update_owner on public.friend_requests for update to authenticated using (to_uid = auth.uid());
  end if;
end $$;

