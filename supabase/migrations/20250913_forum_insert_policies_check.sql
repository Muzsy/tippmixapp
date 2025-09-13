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

-- fixture_id ne legyen kötelező általános threadhez (csak ha létezik az oszlop)
do $$ begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public' and table_name = 'forum_threads' and column_name = 'fixture_id'
  ) then
    begin
      alter table public.forum_threads alter column fixture_id drop not null;
    exception when others then
      -- ignore if already nullable or insufficient privilege
      null;
    end;
  end if;
end $$;
