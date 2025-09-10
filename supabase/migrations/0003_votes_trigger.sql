-- Maintain votes_count on forum_posts via trigger

create or replace function public.update_votes_count()
returns trigger as $$
begin
  if tg_op = 'INSERT' then
    update public.forum_posts set votes_count = votes_count + 1 where id = new.post_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.forum_posts set votes_count = greatest(votes_count - 1, 0) where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_votes_count_ins on public.votes;
create trigger trg_votes_count_ins
after insert on public.votes
for each row execute function public.update_votes_count();

drop trigger if exists trg_votes_count_del on public.votes;
create trigger trg_votes_count_del
after delete on public.votes
for each row execute function public.update_votes_count();

