-- 1) Biztonsági segédfüggvény: jelenlegi user admin-e (ha még nincs, idempotens)
create or replace function public.is_current_user_admin()
returns boolean
language sql
stable
as $$
  select exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and coalesce(p.is_admin, false) = true
  );
$$;

-- 2) Auth user létrejöttekor profil beszúrása
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public as $$
begin
  insert into public.profiles (id, nickname, created_at)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''), now())
  on conflict (id) do nothing;
  return new;
end; $$;

-- 3) Trigger az auth.users-re
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

