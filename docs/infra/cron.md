# Supabase Cron – Tipsterino

- match_finalizer: every 10 minutes, HTTP call to edge function `match_finalizer`
- tickets_payout: every 10 minutes, HTTP call to edge function `tickets_payout`

Notes:
- Use `pg_cron` via SQL or the Supabase Dashboard Scheduler.
- Prefer calling Edge Functions with a service role key from the scheduler secret store.
- Ensure idempotency on server side; batch work to avoid spikes.

Example SQL (pg_cron):

```sql
select cron.schedule(
  'match_finalizer_job',
  '*/10 * * * *',
  $$
  select net.http_post(
    url := 'https://<project-ref>.supabase.co/functions/v1/match_finalizer',
    headers := '{"Authorization": "Bearer '|| current_setting('app.service_role') ||'"}'
  );
  $$
);
```

