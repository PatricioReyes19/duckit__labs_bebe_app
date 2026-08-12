-- Make shared-care activity alerts actionable and descriptive.
-- Run after 202608110002_harden_care_invitation_flow.sql.

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
begin
  notification_kind := case
    when new.deleted_at is not null then 'deleted'
    when tg_op = 'INSERT' then 'created'
    else 'updated'
  end;

  if tg_table_name = 'agenda_events' then
    notification_title := case
      when new.deleted_at is not null then 'Evento de agenda eliminado'
      when tg_op = 'INSERT' then 'Nuevo evento en la agenda'
      else 'Evento de agenda actualizado'
    end;
    notification_body := case
      when new.deleted_at is not null then 'Otro cuidador eliminó un evento compartido.'
      else 'Otro cuidador actualizó la agenda familiar.'
    end;
    notification_route := '/agenda';
    event_type := new.category;
  else
    event_type := new.event_type;
    notification_title := case
      when new.deleted_at is not null then 'Registro eliminado'
      when new.event_type = 'feeding' then 'Nueva alimentación registrada'
      when new.event_type = 'sleep' then 'Nuevo sueño registrado'
      when new.event_type = 'diaper' then 'Nuevo cambio de pañal registrado'
      when new.event_type = 'medication' then 'Nuevo medicamento registrado'
      when new.event_type = 'measurement' then 'Nueva medición registrada'
      when new.event_type = 'clinical_observation' then 'Nueva observación registrada'
      else 'Nuevo registro del bebé'
    end;
    notification_body := case
      when new.deleted_at is not null then 'Otro cuidador eliminó un registro compartido.'
      when new.event_type = 'feeding'
        and nullif(new.details ->> 'amount_ml', '') is not null
        then 'Otro cuidador registró una toma de ' ||
          (new.details ->> 'amount_ml') || ' ml.'
      when new.event_type = 'medication'
        and nullif(new.details ->> 'name', '') is not null
        then 'Otro cuidador registró ' || (new.details ->> 'name') || '.'
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
        'event_type', event_type
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

