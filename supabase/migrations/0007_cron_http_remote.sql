-- Remote CRON HTTP scheduling for Edge Functions (public endpoints)
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    begin
      perform cron.schedule(
        'match_finalizer_http_job',
        '*/10 * * * *',
        $cmd$
          select net.http_post(url := 'https://kqlvckpprogedapetkzp.supabase.co/functions/v1/match_finalizer');
        $cmd$
      );
    exception when others then
      perform 1;
    end;
    begin
      perform cron.schedule(
        'tickets_payout_http_job',
        '*/10 * * * *',
        $cmd$
          select net.http_post(url := 'https://kqlvckpprogedapetkzp.supabase.co/functions/v1/tickets_payout');
        $cmd$
      );
    exception when others then
      perform 1;
    end;
  end if;
end $$;
