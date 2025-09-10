-- Supabase migration: Initial schema for Tipsterino (Firebase -> Supabase)
-- Contains: profiles, forum_threads, forum_posts, votes, tickets, ticket_items, coins_ledger

-- Extensions
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- Tables
create table if not exists public.profiles (
  id uuid primary key,
  nickname text unique not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

comment on table public.profiles is 'User profiles linked to auth.users.id';

create table if not exists public.forum_threads (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.forum_posts (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.forum_threads(id) on delete cascade,
  author uuid not null references public.profiles(id) on delete restrict,
  body text not null,
  votes_count integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.votes (
  post_id uuid not null references public.forum_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists public.ticket_items (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  fixture_id text not null,
  market text not null,
  odd numeric not null,
  selection text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.coins_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  delta integer not null,
  balance_after integer not null,
  ref_id uuid,
  created_at timestamptz not null default now()
);

-- Storage bucket for avatars (idempotent)
insert into storage.buckets (id, name, public)
select 'avatars', 'avatars', false
where not exists (
  select 1 from storage.buckets where id = 'avatars'
);

