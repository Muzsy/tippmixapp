-- Optional: config table for feature flags to replace Remote Config

create table if not exists public.config (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.config enable row level security;

-- readable by all; writes only by service role (bypasses RLS)
do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='config' and policyname='config_read_all') then
    create policy config_read_all on public.config for select using (true);
  end if;
end $$;

-- no insert/update policy for normal clients to ensure only server can write
