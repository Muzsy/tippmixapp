-- Schedule CRON jobs for match_finalizer and tickets_payout if pg_cron is available
do $$
begin
  -- check pg_cron exists
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    -- Placeholders: schedule lightweight no-op commands every 10 minutes.
    -- Remote environment can update commands to HTTP calls via Dashboard.
    begin
      perform cron.schedule('match_finalizer_job', '*/10 * * * *', 'select 1');
    exception when others then
      perform 1;
    end;

    begin
      perform cron.schedule('tickets_payout_job', '*/10 * * * *', 'select 1');
    exception when others then
      perform 1;
    end;
  end if;
end $$;
