create or replace view public.v_rls_effective_policies as
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
from pg_policies
order by schemaname, tablename, policyname;

