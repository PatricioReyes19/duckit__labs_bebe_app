-- BDD-003: one canonical lifecycle for controls and consultations.
-- Additive migration: existing health event IDs and rows are preserved.

alter table public.health_events
  drop constraint if exists health_events_event_type_check;
alter table public.health_events
  drop constraint if exists health_events_status_check;

alter table public.health_events
  add column if not exists appointment_kind text,
  add column if not exists appointment_payload jsonb not null default '{}'::jsonb;

update public.health_events
set appointment_kind = 'wellChildControl'
where appointment_kind is null
  and event_type in ('pediatricControl', 'growthControl');

alter table public.health_events
  add constraint health_events_event_type_check check (
    event_type in (
      'vaccine', 'pediatricControl', 'growthControl', 'consultation'
    )
  ),
  add constraint health_events_status_check check (
    status in (
      'draft', 'scheduled', 'due', 'attendancePending',
      'attendedPendingSummary', 'completed', 'notAttended', 'cancelled',
      'rescheduled'
    )
  ),
  add constraint health_events_appointment_kind_check check (
    appointment_kind is null
    or (appointment_kind = 'consultation' and event_type = 'consultation')
    or (
      appointment_kind = 'wellChildControl'
      and event_type in ('pediatricControl', 'growthControl')
    )
  );

create index if not exists health_appointments_baby_kind_starts_idx
  on public.health_events (baby_id, appointment_kind, starts_at)
  where appointment_kind is not null;

-- Preserve the IDs of legacy consultation records while moving their clinical
-- projection to the canonical aggregate. The legacy rows remain readable by
-- older clients during rollout.
insert into public.health_events (
  id, owner_id, baby_id, event_type, title, description, starts_at,
  caregiver_id, status, appointment_kind, appointment_payload,
  created_at, updated_at, updated_by
)
select
  event.id,
  event.owner_id,
  event.baby_id,
  'consultation',
  coalesce(nullif(event.details ->> 'title', ''), 'Consulta pediátrica'),
  coalesce(event.details ->> 'description', ''),
  event.occurred_at,
  null,
  'completed',
  'consultation',
  jsonb_strip_nulls(jsonb_build_object(
    'reason', event.details ->> 'title',
    'timezone', 'UTC',
    'attended_at', event.occurred_at,
    'completed_at', event.occurred_at,
    'professional_name', event.details ->> 'pediatrician',
    'clinical_summary', event.details ->> 'description',
    'indications', concat_ws(E'\n',
      nullif(event.details ->> 'treatment', ''),
      nullif(event.details ->> 'follow_up', ''),
      nullif(event.details ->> 'vigilance', '')
    ),
    'notes_before_visit', event.notes,
    'created_by', event.owner_id
  )),
  event.created_at,
  event.updated_at,
  event.owner_id
from public.register_events event
where event.event_type = 'clinical_observation'
  and event.deleted_at is null
  and event.details ->> 'observation_type' = 'medical_consultation'
on conflict (id) do nothing;

create or replace function public.apply_health_event(payload jsonb)
returns public.health_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  target_baby_id text := nullif(trim(payload ->> 'baby_id'), '');
  result public.health_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if target_baby_id is null or not exists (
    select 1 from public.babies where id = target_baby_id
  ) then
    raise exception 'Baby must exist before a health event is synchronized'
      using errcode = '23503';
  end if;
  if not public.can_access_baby(target_baby_id, true) then
    raise exception 'Baby write access denied' using errcode = '42501';
  end if;

  insert into public.health_events as target (
    id, owner_id, baby_id, event_type, title, description, starts_at,
    caregiver_id, status, appointment_kind, appointment_payload,
    created_at, updated_at, updated_by
  ) values (
    payload ->> 'id', caller_id, target_baby_id,
    payload ->> 'event_type', payload ->> 'title',
    coalesce(payload ->> 'description', ''),
    (payload ->> 'starts_at')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''), payload ->> 'status',
    nullif(payload ->> 'appointment_kind', ''),
    coalesce(payload -> 'appointment_payload', '{}'::jsonb),
    (payload ->> 'created_at')::timestamptz,
    (payload ->> 'updated_at')::timestamptz, caller_id
  )
  on conflict (id) do update set
    event_type = excluded.event_type,
    title = excluded.title,
    description = excluded.description,
    starts_at = excluded.starts_at,
    caregiver_id = excluded.caregiver_id,
    status = excluded.status,
    appointment_kind = excluded.appointment_kind,
    appointment_payload = excluded.appointment_payload,
    updated_at = excluded.updated_at,
    updated_by = excluded.updated_by
  where target.baby_id = excluded.baby_id
    and public.can_access_baby(target.baby_id, true)
    and target.updated_at <= excluded.updated_at
  returning * into result;

  if result is null then
    select * into result
    from public.health_events
    where id = payload ->> 'id'
      and public.can_access_baby(baby_id);
  end if;
  return result;
end;
$$;

revoke all on function public.apply_health_event(jsonb) from public;
grant execute on function public.apply_health_event(jsonb)
  to anon, authenticated;

;
