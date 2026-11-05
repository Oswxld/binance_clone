-- Existing g_messages AFTER INSERT trigger continues creating notifications.
-- Only the withdrawal kind uses the Binance notification title; all other
-- message kinds retain the original Deriv title.
create or replace function public.handle_new_g_message_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $body$
begin
  insert into public.g_notifications (owner_id, message_id, title, body)
  values (
    new.owner_id,
    new.id,
    case when new.kind = 'withdrawal' then 'Binance' else 'Deriv' end,
    new.body
  );
  return new;
end;
$body$;
