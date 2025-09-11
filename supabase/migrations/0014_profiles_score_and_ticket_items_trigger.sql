-- Add score column to profiles and a trigger to increment on new ticket item (as 'tip')

do $$ begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'profiles' and column_name = 'score'
  ) then
    alter table public.profiles add column score integer default 0;
  end if;
end $$;

create or replace function public.compute_score_on_ticket_item()
returns trigger as $$
begin
  -- Increase user's score by 1 for each new ticket item (tip)
  update public.profiles set score = coalesce(score, 0) + 1
  where id = new.user_id;
  return new;
end;
$$ language plpgsql;

-- Safely create trigger if not exists
do $$ begin
  if not exists (
    select 1 from pg_trigger where tgname = 'ticket_items_after_insert_score' and tgrelid = 'public.ticket_items'::regclass
  ) then
    create trigger ticket_items_after_insert_score
      after insert on public.ticket_items
      for each row execute function public.compute_score_on_ticket_item();
  end if;
end $$;

