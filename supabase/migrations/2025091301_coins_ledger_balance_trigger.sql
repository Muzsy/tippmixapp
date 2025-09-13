create or replace function public.fn_coins_ledger_set_balance_after()
returns trigger as $$
declare v_prev int; begin
  select coalesce(sum(delta),0) into v_prev from public.coins_ledger where user_id=new.user_id;
  new.balance_after := v_prev + new.delta;
  return new; end; $$ language plpgsql;

drop trigger if exists trg_coins_ledger_balance on public.coins_ledger;
create trigger trg_coins_ledger_balance
before insert on public.coins_ledger
for each row execute function public.fn_coins_ledger_set_balance_after();

