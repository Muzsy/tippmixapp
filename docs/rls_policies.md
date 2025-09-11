RLS Policies – Tipsterino (Supabase)

- profiles: owner can read/write own row; admin can read all.
- forum_threads: public read; authenticated insert/update by owner; admin read all.
- forum_posts: public read; authenticated insert/update by owner; admin read all.
- votes: public read; insert/delete by owner.
- tickets: owner full access; admin read all.
- ticket_items: owner full access via ticket ownership; admin read all.
- coins_ledger: owner read; writes via service role only.
- badges, followers, friend_requests: owner-only policies.
- notifications, copied_bets, public_feed, moderation_reports, user_settings: owner-only policies as per migrations.

