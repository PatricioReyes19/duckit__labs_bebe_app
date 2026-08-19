-- Connect Baby-owned aggregates and public profile references without
-- changing Firebase Third-Party Auth or the historical owner/audit columns.
-- Created as the next repository migration; applied migrations remain intact.

-- PREFLIGHT -----------------------------------------------------------------

do $$
declare
  invalid_ids text;
begin
  select string_agg(source || ':' || quote_nullable(user_id), ', ')
  into invalid_ids
  from (
    select 'push_devices' as source, user_id from public.push_devices
    union all
    select 'user_preferences', user_id from public.user_preferences
    union all
    select 'baby_caregivers', user_id from public.baby_caregivers
  ) references_to_profiles
  where nullif(trim(user_id), '') is null
     or char_length(user_id) > 128;

  if invalid_ids is not null then
    raise exception 'Cannot add profile foreign keys; empty user ids: %',
      invalid_ids using errcode = '23503';
  end if;
end;
$$;
-- Every non-empty UID already referenced by a user-owned table is an existing
-- Firebase identity in the current data model. Preserve it with a minimal
-- public profile rather than deleting the referencing row.
insert into public.profiles (id)
select distinct user_id
from (
  select user_id from public.push_devices
  union
  select user_id from public.user_preferences
  union
  select user_id from public.baby_caregivers
) references_to_profiles
where nullif(trim(user_id), '') is not null
  and char_length(user_id) <= 128
on conflict (id) do nothing;
do $$
declare
  orphan_sample text;
begin
  select string_agg(id || '->' || baby_id, ', ')
  into orphan_sample
  from (
    select event.id, event.baby_id
    from public.register_events event
    left join public.babies baby on baby.id = event.baby_id
    where baby.id is null
    order by event.id
    limit 20
  ) orphan;

  if orphan_sample is not null then
    raise exception
      'Cannot add register_events.baby_id FK; orphan rows: %', orphan_sample
      using errcode = '23503',
        hint = 'Hydrate or restore the canonical Baby; do not create placeholders or delete offline history.';
  end if;

  select string_agg(id || '->' || baby_id, ', ')
  into orphan_sample
  from (
    select event.id, event.baby_id
    from public.agenda_events event
    left join public.babies baby on baby.id = event.baby_id
    where baby.id is null
    order by event.id
    limit 20
  ) orphan;

  if orphan_sample is not null then
    raise exception
      'Cannot add agenda_events.baby_id FK; orphan rows: %', orphan_sample
      using errcode = '23503',
        hint = 'Restore the canonical Baby before applying this migration.';
  end if;

  select string_agg(id || '->' || source_register_event_id, ', ')
  into orphan_sample
  from (
    select event.id, event.source_register_event_id
    from public.agenda_events event
    left join public.register_events source
      on source.id = event.source_register_event_id
    where event.source_register_event_id is not null
      and source.id is null
    order by event.id
    limit 20
  ) orphan;

  if orphan_sample is not null then
    raise exception
      'Cannot add agenda source FK; orphan rows: %', orphan_sample
      using errcode = '23503',
        hint = 'Restore the source register event or explicitly clear the invalid relationship.';
  end if;
end;
$$;
-- CONSTRAINTS ---------------------------------------------------------------

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'push_devices_user_id_fkey'
      and conrelid = 'public.push_devices'::regclass
  ) then
    alter table public.push_devices
      add constraint push_devices_user_id_fkey
      foreign key (user_id) references public.profiles(id)
      on delete cascade not valid;
    alter table public.push_devices
      validate constraint push_devices_user_id_fkey;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'user_preferences_user_id_fkey'
      and conrelid = 'public.user_preferences'::regclass
  ) then
    alter table public.user_preferences
      add constraint user_preferences_user_id_fkey
      foreign key (user_id) references public.profiles(id)
      on delete cascade not valid;
    alter table public.user_preferences
      validate constraint user_preferences_user_id_fkey;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'baby_caregivers_user_id_fkey'
      and conrelid = 'public.baby_caregivers'::regclass
  ) then
    alter table public.baby_caregivers
      add constraint baby_caregivers_user_id_fkey
      foreign key (user_id) references public.profiles(id)
      on delete cascade not valid;
    alter table public.baby_caregivers
      validate constraint baby_caregivers_user_id_fkey;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'register_events_baby_id_fkey'
      and conrelid = 'public.register_events'::regclass
  ) then
    alter table public.register_events
      add constraint register_events_baby_id_fkey
      foreign key (baby_id) references public.babies(id)
      on delete cascade not valid;
    alter table public.register_events
      validate constraint register_events_baby_id_fkey;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'agenda_events_baby_id_fkey'
      and conrelid = 'public.agenda_events'::regclass
  ) then
    alter table public.agenda_events
      add constraint agenda_events_baby_id_fkey
      foreign key (baby_id) references public.babies(id)
      on delete cascade not valid;
    alter table public.agenda_events
      validate constraint agenda_events_baby_id_fkey;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'agenda_events_source_register_event_id_fkey'
      and conrelid = 'public.agenda_events'::regclass
  ) then
    alter table public.agenda_events
      add constraint agenda_events_source_register_event_id_fkey
      foreign key (source_register_event_id)
      references public.register_events(id)
      on delete set null not valid;
    alter table public.agenda_events
      validate constraint agenda_events_source_register_event_id_fkey;
  end if;
end;
$$;
-- Preserve compatibility for authenticated Firebase users referenced by old
-- RPCs. Only the current JWT subject may receive an automatic minimal profile;
-- arbitrary caregiver ids must already exist and otherwise fail the FK.
create or replace function public.ensure_current_user_profile_reference()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
begin
  if not exists (select 1 from public.profiles where id = new.user_id)
     and new.user_id = caller_id
     and public.is_bebeapp_firebase_user() then
    insert into public.profiles (id) values (new.user_id)
    on conflict (id) do nothing;
  end if;
  return new;
end;
$$;
revoke all on function public.ensure_current_user_profile_reference()
  from public;
drop trigger if exists baby_caregivers_ensure_profile
  on public.baby_caregivers;
create trigger baby_caregivers_ensure_profile
before insert or update of user_id on public.baby_caregivers
for each row execute function public.ensure_current_user_profile_reference();
drop trigger if exists push_devices_ensure_profile on public.push_devices;
create trigger push_devices_ensure_profile
before insert or update of user_id on public.push_devices
for each row execute function public.ensure_current_user_profile_reference();
drop trigger if exists user_preferences_ensure_profile
  on public.user_preferences;
create trigger user_preferences_ensure_profile
before insert or update of user_id on public.user_preferences
for each row execute function public.ensure_current_user_profile_reference();
-- RLS -----------------------------------------------------------------------
-- Identity remains in profiles; authorization remains baby_caregivers + Baby.

drop policy if exists "register events select own" on public.register_events;
drop policy if exists "register events insert own" on public.register_events;
drop policy if exists "register events update own" on public.register_events;
drop policy if exists "register events select care circle"
  on public.register_events;
drop policy if exists "register events insert care circle"
  on public.register_events;
drop policy if exists "register events update care circle"
  on public.register_events;
create policy "register events select care circle"
  on public.register_events for select to anon, authenticated
  using ((select public.can_access_baby(baby_id)));
create policy "register events insert care circle"
  on public.register_events for insert to anon, authenticated
  with check (
    (select public.can_access_baby(baby_id, true))
    and owner_id = auth.jwt() ->> 'sub'
    and updated_by = auth.jwt() ->> 'sub'
  );
create policy "register events update care circle"
  on public.register_events for update to anon, authenticated
  using ((select public.can_access_baby(baby_id, true)))
  with check (
    (select public.can_access_baby(baby_id, true))
    and updated_by = auth.jwt() ->> 'sub'
  );
drop policy if exists "agenda events select own" on public.agenda_events;
drop policy if exists "agenda events insert own" on public.agenda_events;
drop policy if exists "agenda events update own" on public.agenda_events;
drop policy if exists "agenda events select care circle"
  on public.agenda_events;
drop policy if exists "agenda events insert care circle"
  on public.agenda_events;
drop policy if exists "agenda events update care circle"
  on public.agenda_events;
create policy "agenda events select care circle"
  on public.agenda_events for select to anon, authenticated
  using ((select public.can_access_baby(baby_id)));
create policy "agenda events insert care circle"
  on public.agenda_events for insert to anon, authenticated
  with check (
    (select public.can_access_baby(baby_id, true))
    and owner_id = auth.jwt() ->> 'sub'
    and updated_by = auth.jwt() ->> 'sub'
  );
create policy "agenda events update care circle"
  on public.agenda_events for update to anon, authenticated
  using ((select public.can_access_baby(baby_id, true)))
  with check (
    (select public.can_access_baby(baby_id, true))
    and updated_by = auth.jwt() ->> 'sub'
  );
-- RPCS ----------------------------------------------------------------------
-- `owner_id` remains the historical creator for compatibility. Baby is the
-- aggregate owner and must already have been synchronized by FamilySync.

create or replace function public.apply_register_event(payload jsonb)
returns public.register_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  target_baby_id text := nullif(trim(payload ->> 'baby_id'), '');
  result public.register_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if target_baby_id is null or not exists (
    select 1 from public.babies where id = target_baby_id
  ) then
    raise exception 'Baby must exist before a register event is synchronized'
      using errcode = '23503';
  end if;
  if not public.can_access_baby(target_baby_id, true) then
    raise exception 'Write access denied' using errcode = '42501';
  end if;

  insert into public.register_events as target (
    id, owner_id, baby_id, event_type, occurred_at, created_at, updated_at,
    deleted_at, caregiver_id, notes, details, schema_version, updated_by
  ) values (
    payload ->> 'id', caller_id, target_baby_id, payload ->> 'event_type',
    (payload ->> 'occurred_at')::timestamptz,
    (payload ->> 'created_at')::timestamptz,
    (payload ->> 'updated_at')::timestamptz,
    nullif(payload ->> 'deleted_at', '')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''),
    nullif(payload ->> 'notes', ''),
    coalesce(payload -> 'details', '{}'::jsonb),
    coalesce((payload ->> 'schema_version')::integer, 1),
    caller_id
  )
  on conflict (id) do update set
    event_type = excluded.event_type,
    occurred_at = excluded.occurred_at,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at,
    caregiver_id = excluded.caregiver_id,
    notes = excluded.notes,
    details = excluded.details,
    schema_version = excluded.schema_version,
    updated_by = caller_id
  where target.baby_id = excluded.baby_id
    and public.can_access_baby(target.baby_id, true)
    and excluded.updated_at >= target.updated_at
  returning * into result;

  if result.id is null then
    select * into result from public.register_events
    where id = payload ->> 'id'
      and public.can_access_baby(baby_id);
  end if;
  return result;
end;
$$;
create or replace function public.apply_agenda_event(payload jsonb)
returns public.agenda_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  target_baby_id text := nullif(trim(payload ->> 'baby_id'), '');
  source_event_id text := nullif(payload ->> 'source_register_event_id', '');
  result public.agenda_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if target_baby_id is null or not exists (
    select 1 from public.babies where id = target_baby_id
  ) then
    raise exception 'Baby must exist before an agenda event is synchronized'
      using errcode = '23503';
  end if;
  if not public.can_access_baby(target_baby_id, true) then
    raise exception 'Write access denied' using errcode = '42501';
  end if;
  if source_event_id is not null and not exists (
    select 1 from public.register_events source
    where source.id = source_event_id
      and source.baby_id = target_baby_id
  ) then
    raise exception 'Agenda source register event is missing or belongs to another Baby'
      using errcode = '23503';
  end if;

  insert into public.agenda_events as target (
    id, owner_id, baby_id, category, title, description, starts_at,
    created_at, updated_at, deleted_at, caregiver_id,
    source_register_event_id, updated_by
  ) values (
    payload ->> 'id', caller_id, target_baby_id, payload ->> 'category',
    payload ->> 'title', coalesce(payload ->> 'description', ''),
    (payload ->> 'starts_at')::timestamptz,
    (payload ->> 'created_at')::timestamptz,
    (payload ->> 'updated_at')::timestamptz,
    nullif(payload ->> 'deleted_at', '')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''), source_event_id, caller_id
  )
  on conflict (id) do update set
    category = excluded.category,
    title = excluded.title,
    description = excluded.description,
    starts_at = excluded.starts_at,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at,
    caregiver_id = excluded.caregiver_id,
    source_register_event_id = excluded.source_register_event_id,
    updated_by = caller_id
  where target.baby_id = excluded.baby_id
    and public.can_access_baby(target.baby_id, true)
    and excluded.updated_at >= target.updated_at
  returning * into result;

  if result.id is null then
    select * into result from public.agenda_events
    where id = payload ->> 'id'
      and public.can_access_baby(baby_id);
  end if;
  return result;
end;
$$;
-- Health already had a Baby FK, but its historical RPC still called
-- bootstrap_baby. Keep all Baby-owned writes under the same parent-first
-- contract so a child write can never manufacture a placeholder aggregate.
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
    caregiver_id, status, created_at, updated_at, updated_by
  ) values (
    payload ->> 'id', caller_id, target_baby_id,
    payload ->> 'event_type', payload ->> 'title',
    coalesce(payload ->> 'description', ''),
    (payload ->> 'starts_at')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''), payload ->> 'status',
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
revoke all on function public.apply_register_event(jsonb) from public;
revoke all on function public.apply_agenda_event(jsonb) from public;
revoke all on function public.apply_health_event(jsonb) from public;
grant execute on function public.apply_register_event(jsonb)
  to anon, authenticated;
grant execute on function public.apply_agenda_event(jsonb)
  to anon, authenticated;
grant execute on function public.apply_health_event(jsonb)
  to anon, authenticated;
-- caregiver_id intentionally has no remote FK in this migration. Local rows
-- currently store family_members.id while remote membership uses
-- baby_caregivers(user_id, baby_id); choosing profiles(id) would be incorrect.;
