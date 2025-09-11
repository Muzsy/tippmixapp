-- User settings table for preferences and onboarding flags

create table if not exists public.user_settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  notification_prefs jsonb not null default '{}',
  theme_scheme_index integer,
  theme_is_dark boolean,
  onboarding_completed boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.user_settings enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='user_settings' and policyname='user_settings_owner_rw') then
    create policy user_settings_owner_rw on public.user_settings
      for all to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;
end $$;

