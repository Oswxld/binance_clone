-- DEMO ONLY: deployed to Supabase in October 2026.
-- Deducts an amount from the authenticated user's OWN b_balances row.
-- Entered recipient account is purely a UI prop; no recipient receives funds.
-- Never use this as a payment or value-transfer mechanism.
create or replace function public.b_demo_send_deduct(
    p_asset text, p_amount numeric
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $body$
declare
  v_owner uuid := (select auth.uid());
  v_usdt numeric;
  v_btc numeric;
begin
  if v_owner is null then
    raise exception 'Sign in to access the demo wallet';
  end if;
  if p_asset is null or p_asset not in ('USDT','BTC') then
    raise exception 'Unsupported demo asset';
  end if;
  if p_amount is null or p_amount <= 0
     or p_amount <> trunc(p_amount, 10) then
    raise exception 'Enter a positive amount with at most ten decimal places';
  end if;

  update public.b_balances
     set usdt_balance = case when p_asset = 'USDT'
                              then usdt_balance - p_amount
                              else usdt_balance end,
         btc_balance = case when p_asset = 'BTC'
                             then btc_balance - p_amount
                             else btc_balance end,
         updated_at = now()
   where owner_id = v_owner
     and (case when p_asset = 'USDT' then usdt_balance
               else btc_balance end) >= p_amount
  returning usdt_balance, btc_balance into v_usdt, v_btc;

  if not found then
    raise exception 'Insufficient demo balance or no wallet for this account';
  end if;

  return jsonb_build_object('asset',p_asset,'deducted',p_amount,
    'usdt_balance',v_usdt,'btc_balance',v_btc,'demo',true);
end;
$body$;

revoke execute on function public.b_demo_send_deduct(text,numeric)
  from public, anon;
grant execute on function public.b_demo_send_deduct(text,numeric)
  to authenticated;
