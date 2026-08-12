-- Make delayed offline uploads understandable to the other caregivers. The
-- durable activity row feeds Realtime (INAPP/dot) and the Firebase webhook.

create or replace function public.notify_care_circle_activity()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  recipient record;
  notification_kind text;
  notification_title text;
  notification_body text;
  notification_route text;
  event_type text;
  event_time timestamptz;
  delayed_sync boolean :=
    tg_op = 'INSERT' and new.updated_at < now() - interval '2 minutes';
begin
  notification_kind := case
    when new.deleted_at is not null then 'deleted'
    when delayed_sync then 'synced_offline'
    when tg_op = 'INSERT' then 'created'
    else 'updated'
  end;

  if tg_table_name = 'agenda_events' then
    event_type := new.category;
    event_time := new.starts_at;
    notification_title := case
      when new.deleted_at is not null then 'Evento de agenda eliminado'
      when delayed_sync then 'Agenda sincronizada'
      when tg_op = 'INSERT' then 'Nuevo evento en la agenda'
      else 'Evento de agenda actualizado'
    end;
    notification_body := case
      when new.deleted_at is not null then
        'Otro cuidador eliminó un evento compartido.'
      when delayed_sync then
        'Se recibió un evento que otro cuidador creó sin conexión.'
      else 'Otro cuidador actualizó la agenda familiar.'
    end;
    notification_route := '/agenda';
  else
    event_type := new.event_type;
    event_time := new.occurred_at;
    notification_title := case
      when new.deleted_at is not null then 'Registro eliminado'
      when delayed_sync then 'Registro offline sincronizado'
      when new.event_type = 'feeding' then 'Nueva alimentación registrada'
      when new.event_type = 'sleep' then 'Nuevo sueño registrado'
      when new.event_type = 'diaper' then 'Nuevo cambio de pañal registrado'
      when new.event_type = 'medication' then 'Nuevo medicamento registrado'
      when new.event_type = 'measurement' then 'Nueva medición registrada'
      when new.event_type = 'clinical_observation' then
        'Nueva observación registrada'
      else 'Nuevo registro del bebé'
    end;
    notification_body := case
      when new.deleted_at is not null then
        'Otro cuidador eliminó un registro compartido.'
      when delayed_sync and new.event_type = 'feeding' then
        'Se sincronizó una alimentación que otro cuidador registró sin conexión.'
      when delayed_sync and new.event_type = 'diaper' then
        'Se sincronizó un cambio de pañal registrado sin conexión.'
      when delayed_sync then
        'Se sincronizó actividad que otro cuidador registró sin conexión.'
      when new.event_type = 'feeding'
        and nullif(new.details ->> 'amount_ml', '') is not null then
          'Otro cuidador registró una toma de ' ||
          (new.details ->> 'amount_ml') || ' ml.'
      when new.event_type = 'medication'
        and nullif(new.details ->> 'name', '') is not null then
          'Otro cuidador registró ' || (new.details ->> 'name') || '.'
      else 'Otro cuidador agregó actividad al historial compartido.'
    end;
    notification_route := '/home/history';
  end if;

  for recipient in
    select membership.user_id
    from public.baby_caregivers membership
    where membership.baby_id = new.baby_id
      and membership.user_id <> new.updated_by
  loop
    insert into public.activity_notifications (
      recipient_id, actor_id, baby_id, kind, title, body, route, payload,
      source_table, source_id, source_updated_at
    ) values (
      recipient.user_id,
      new.updated_by,
      new.baby_id,
      notification_kind,
      notification_title,
      notification_body,
      notification_route,
      jsonb_build_object(
        'actor_id', new.updated_by,
        'baby_id', new.baby_id,
        'source_table', tg_table_name,
        'source_id', new.id,
        'kind', notification_kind,
        'event_type', event_type,
        'event_time', event_time,
        'delayed_sync', delayed_sync
      ),
      tg_table_name,
      new.id,
      new.updated_at
    )
    on conflict (recipient_id, source_table, source_id, source_updated_at)
      do nothing;
  end loop;
  return new;
end;
$$;
