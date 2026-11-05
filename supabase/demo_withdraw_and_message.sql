-- Applied in the connected Supabase project.
-- An owner-scoped simulated withdrawal debits USDT and inserts exactly one
-- g_messages row in the SAME database transaction.
-- Use the returned transaction_id only as a local display reference.
create or replace function public.b_demo_withdraw_and_message(
  p_amount numeric,
  p_address text
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $body$
declare
  v_owner uuid := (select auth.uid());
  v_time timestamptz := clock_timestamp();
  v_subject text;
  v_body text;
  v_txid text;
  v_id uuid;
  v_balance numeric;
  v_address text := btrim(p_address);
begin
  if v_owner is null then
    raise exception 'Sign in before withdrawing';
  end if;
  if p_amount is null or p_amount <= 0
      or p_amount <> trunc(p_amount, 10) then
    raise exception 'Enter a positive amount with at most ten decimal places';
  end if;
  if v_address is null or v_address = '' or length(v_address) > 512 then
    raise exception 'Enter an address (at most 512 characters)';
  end if;

  update public.b_balances
    set usdt_balance = usdt_balance - p_amount,
        updated_at = v_time
    where owner_id = v_owner
      and usdt_balance >= p_amount
    returning usdt_balance into v_balance;

  if not found then
    raise exception 'Insufficient balance or no wallet for this account';
  end if;

  v_subject := 'USDT Withdrawal successful ' ||
    to_char(v_time at time zone 'UTC', 'YYYY-MM-DD HH24:MI:SS') || ' UTC';
  v_body := 'You have simulated a withdrawal of ' ||
    p_amount::text || ' USDT';
  v_txid := encode(extensions.gen_random_bytes(50), 'hex');

  insert into public.g_messages (
    owner_id, sender_name, subject, body, body2,
    withdrawal_address, transaction_id, kind,
    received_at, preview, avatar_letter, avatar_color, category
  )
  values (
    v_owner, 'Binance', v_subject, v_body, v_subject,
    v_address, v_txid, 'withdrawal',
    v_time, v_body, 'B', '#F0B90B', 'primary'
  )
  returning id into v_id;

  return jsonb_build_object(
    'message_id', v_id,
    'transaction_id', v_txid,
    'created_at_utc', to_char(v_time at time zone 'UTC',
                                'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'usdt_balance', v_balance
  );
end;
$body$;

revoke execute on function public.b_demo_withdraw_and_message(numeric,text)
  from public, anon;
grant execute on function public.b_demo_withdraw_and_message(numeric,text)
  to authenticated;
