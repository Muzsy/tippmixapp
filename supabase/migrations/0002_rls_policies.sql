-- Enable RLS and define policies

-- Profiles: everyone can read, only owner can insert/update/delete
alter table public.profiles enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'profiles' and policyname = 'profiles_read_all'
  ) then
    create policy profiles_read_all on public.profiles for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'profiles' and policyname = 'profiles_owner_write'
  ) then
    create policy profiles_owner_write on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
  end if;
end $$;

-- Forum: public read, authenticated write
alter table public.forum_threads enable row level security;
alter table public.forum_posts enable row level security;
alter table public.votes enable row level security;

-- forum_threads
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_threads' and policyname='forum_threads_read_all') then
    create policy forum_threads_read_all on public.forum_threads for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_threads' and policyname='forum_threads_insert_auth') then
    create policy forum_threads_insert_auth on public.forum_threads for insert to authenticated with check (author = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_threads' and policyname='forum_threads_update_owner') then
    create policy forum_threads_update_owner on public.forum_threads for update to authenticated using (author = auth.uid());
  end if;
end $$;

-- forum_posts
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_posts' and policyname='forum_posts_read_all') then
    create policy forum_posts_read_all on public.forum_posts for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_posts' and policyname='forum_posts_insert_auth') then
    create policy forum_posts_insert_auth on public.forum_posts for insert to authenticated with check (author = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='forum_posts' and policyname='forum_posts_update_owner') then
    create policy forum_posts_update_owner on public.forum_posts for update to authenticated using (author = auth.uid());
  end if;
end $$;

-- votes: only owner can insert/delete own vote; readable by all
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='votes' and policyname='votes_read_all') then
    create policy votes_read_all on public.votes for select using (true);
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='votes' and policyname='votes_insert_owner') then
    create policy votes_insert_owner on public.votes for insert to authenticated with check (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='votes' and policyname='votes_delete_owner') then
    create policy votes_delete_owner on public.votes for delete to authenticated using (user_id = auth.uid());
  end if;
end $$;

-- Tickets and items: only owner can select/insert/update/delete
alter table public.tickets enable row level security;
alter table public.ticket_items enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='tickets' and policyname='tickets_owner_all') then
    create policy tickets_owner_all on public.tickets for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='ticket_items' and policyname='ticket_items_owner_all') then
    create policy ticket_items_owner_all on public.ticket_items for all to authenticated using (
      exists (select 1 from public.tickets t where t.id = ticket_id and t.user_id = auth.uid())
    ) with check (
      exists (select 1 from public.tickets t where t.id = ticket_id and t.user_id = auth.uid())
    );
  end if;
end $$;

-- coins_ledger: read/write restricted; reads by owner; writes by service role only
alter table public.coins_ledger enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='coins_ledger' and policyname='coins_ledger_owner_read') then
    create policy coins_ledger_owner_read on public.coins_ledger for select to authenticated using (user_id = auth.uid());
  end if;
end $$;

-- Service role bypasses RLS; do not create insert policies for normal clients.
