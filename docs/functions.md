Supabase Functions and Triggers

- Tip score update: profiles.score increments by 1 after inserting a new ticket item (tip) via trigger `ticket_items_after_insert_score` using `compute_score_on_ticket_item()`.
- Notifications: Edge Function `notify_user` (Deno) acknowledges notification events; extend to send emails or push as needed.

See: `supabase/migrations/0014_profiles_score_and_ticket_items_trigger.sql`, `supabase/functions/notify_user/`.

