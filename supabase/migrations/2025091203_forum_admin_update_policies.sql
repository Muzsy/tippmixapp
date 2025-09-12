-- Csak admin módosíthassa a pinned/locked mezőket a forum_threads táblán
create policy forum_threads_admin_update
  on public.forum_threads for update to authenticated
  using (public.is_current_user_admin())
  with check (public.is_current_user_admin());

-- (Opcionális) szerző saját threadjén továbbra is szerkeszthessen – ha külön policy-val kezeled
-- create policy forum_threads_author_update ...

