-- Auto-creating profiles on new auth.users and backfilling missing profiles
-- Includes trigger function, trigger, and one-time backfill.

-- 1) Trigger function: on new auth.users row, insert a matching public.profiles row
create or replace function public.handle_new_user()
returns trigger as '
begin
  insert into public.profiles (id, nickname)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data->>''nickname''), ''''),
      nullif(trim(split_part(new.email, ''@'', 1)), ''''),
      ''user_''||substr(new.id::text, 1, 8)
    )
  )
  on conflict (id) do nothing;
  return new;
end;
'
language plpgsql;

-- 2) Trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3) Backfill any missing profiles for existing auth.users
insert into public.profiles (id, nickname)
select u.id,
       coalesce(
         nullif(trim(u.raw_user_meta_data->>'nickname'), ''),
         nullif(trim(split_part(u.email, '@', 1)), ''),
         'user_'||substr(u.id::text, 1, 8)
       ) as nickname
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null
on conflict (id) do nothing;

-- 4) RLS/policies: already defined in earlier migrations (0002). Kept here for reference only.
