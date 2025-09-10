-- Remote CRON scheduling for Edge Functions (use with psql on the remote DB)
-- Replace <project-ref> with your project ref, and ensure pg_cron + pg_net are available.

do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule(
      'match_finalizer_job',
      '*/10 * * * *',
      $cmd$
        select net.http_post(
          url := 'https://<project-ref>.supabase.co/functions/v1/match_finalizer',
          headers := '{"Authorization": "Bearer ' || current_setting('app.settings.service_role') || '"}'
        );
      $cmd$
    );
    perform cron.schedule(
      'tickets_payout_job',
      '*/10 * * * *',
      $cmd$
        select net.http_post(
          url := 'https://<project-ref>.supabase.co/functions/v1/tickets_payout',
          headers := '{"Authorization": "Bearer ' || current_setting('app.settings.service_role') || '"}'
        );
      $cmd$
    );
  end if;
end $$;

