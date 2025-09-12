# Tickets → Profiles FK Error Fix (Supabase)

Problem: inserting into  fails with FK error  because  is missing for some users.

Fixes applied:

- DB trigger  on  creates a matching  row for each new user.
- One-time backfill inserts any missing profiles for existing users.
- RLS/policies were already present (see ).
- App already calls an idempotent  after sign-in/registration ().

Migration file:

- 

Verification (local):

- Apply migrations: Local database is up to date..
- Sign up a new test user (or insert into ): a  row appears automatically.
- Insert into  with  succeeds (no FK error).

