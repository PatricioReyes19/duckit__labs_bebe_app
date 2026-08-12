-- Complete the offline-first data contract for Family, Health and Settings.
-- Register, Agenda, invitations, push devices and the notification inbox are
-- created by migrations 202608100001..004.

create extension if not exists pgcrypto;
-- FAMILY --------------------------------------------------------------------

create table if not exists public.families (
  id text primary key,
  name text not null,
  created_by text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.babies add column if not exists family_id text;
alter table public.babies add column if not exists birth_date timestamptz;
alter table public.babies add column if not exists updated_by text;
-- Old installations had one remote baby without a family aggregate. Preserve
-- those rows by assigning a deterministic family before adding the FK.
insert into public.families (id, name, created_by, created_at, updated_at)
select
  'family-' || md5(baby.id),
  'Mi familia',
  baby.created_by,
  baby.created_at,
  baby.updated_at
from public.babies baby
where baby.family_id is null
on conflict (id) do nothing;
update public.babies baby
set family_id = 'family-' || md5(baby.id)
where baby.family_id is null;
update public.babies
set birth_date = coalesce(birth_date, created_at),
    updated_by = coalesce(updated_by, created_by)
where birth_date is null or updated_by is null;
-- Keep these columns nullable for backward compatibility with the bootstrap
-- and invitation RPCs from already released clients. The new family snapshot
-- always supplies all three values and the backfill above fixes existing rows.

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'babies_family_id_fkey'
      and conrelid = 'public.babies'::regclass
  ) then
    alter table public.babies
      add constraint babies_family_id_fkey
      foreign key (family_id) references public.families(id) on delete cascade;
  end if;
end;
$$;
create index if not exists families_updated_idx
  on public.families (updated_at, id);
create index if not exists babies_family_updated_idx
  on public.babies (family_id, updated_at, id);
alter table public.families enable row level security;
create or replace function public.can_access_family(target_family_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.babies baby
    join public.baby_caregivers membership on membership.baby_id = baby.id
    where baby.family_id = target_family_id
      and membership.user_id = auth.jwt() ->> 'sub'
  );
$$;
revoke all on function public.can_access_family(text) from public;
grant execute on function public.can_access_family(text) to anon, authenticated;
drop policy if exists "families select members" on public.families;
create policy "families select members"
  on public.families for select to anon, authenticated
  using ((select public.can_access_family(id)));
drop policy if exists "families insert creator" on public.families;
create policy "families insert creator"
  on public.families for insert to anon, authenticated
  with check (
    (select public.is_bebeapp_firebase_user())
    and created_by = auth.jwt() ->> 'sub'
  );
drop policy if exists "families update members" on public.families;
create policy "families update members"
  on public.families for update to anon, authenticated
  using ((select public.can_access_family(id)))
  with check ((select public.can_access_family(id)));
drop policy if exists "babies update members" on public.babies;
create policy "babies update members"
  on public.babies for update to anon, authenticated
  using ((select public.can_access_baby(id, true)))
  with check ((select public.can_access_baby(id, true)));
-- A family member must be able to resolve the display names of the other
-- members returned by baby_caregivers.
drop policy if exists "profiles select shared caregivers" on public.profiles;
create policy "profiles select shared caregivers"
  on public.profiles for select to anon, authenticated
  using (
    (select public.is_bebeapp_firebase_user())
    and exists (
      select 1
      from public.baby_caregivers mine
      join public.baby_caregivers theirs on theirs.baby_id = mine.baby_id
      where mine.user_id = auth.jwt() ->> 'sub'
        and theirs.user_id = profiles.id
    )
  );
grant select, insert, update on public.families to anon, authenticated;
create or replace function public.apply_family_snapshot(payload jsonb)
returns public.families
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  family_id text := nullif(trim(payload ->> 'family_id'), '');
  incoming_updated_at timestamptz := (payload ->> 'updated_at')::timestamptz;
  baby_payload jsonb;
  result public.families;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if family_id is null or incoming_updated_at is null then
    raise exception 'family_id and updated_at are required' using errcode = '22023';
  end if;
  if exists (select 1 from public.families where id = family_id)
     and not public.can_access_family(family_id) then
    raise exception 'Family access denied' using errcode = '42501';
  end if;

  insert into public.families as target (
    id, name, created_by, created_at, updated_at
  ) values (
    family_id,
    coalesce(nullif(trim(payload ->> 'family_name'), ''), 'Mi familia'),
    caller_id,
    incoming_updated_at,
    incoming_updated_at
  )
  on conflict (id) do update set
    name = excluded.name,
    updated_at = excluded.updated_at
  where target.updated_at <= excluded.updated_at;

  for baby_payload in
    select value from jsonb_array_elements(coalesce(payload -> 'babies', '[]'))
  loop
    insert into public.babies as target (
      id, family_id, display_name, birth_date, created_by, created_at,
      updated_at, updated_by
    ) values (
      baby_payload ->> 'id',
      family_id,
      coalesce(nullif(trim(baby_payload ->> 'display_name'), ''), 'Bebé'),
      (baby_payload ->> 'birth_date')::timestamptz,
      caller_id,
      incoming_updated_at,
      incoming_updated_at,
      caller_id
    )
    on conflict (id) do update set
      family_id = excluded.family_id,
      display_name = excluded.display_name,
      birth_date = excluded.birth_date,
      updated_at = excluded.updated_at,
      updated_by = excluded.updated_by
    where (
        target.family_id = excluded.family_id
        or public.can_access_baby(target.id, true)
      )
      and target.updated_at <= excluded.updated_at;

    if exists (
      select 1
      from public.babies baby
      where baby.id = baby_payload ->> 'id'
        and baby.family_id = family_id
        and (
          baby.created_by = caller_id
          or public.can_access_baby(baby.id, true)
        )
    ) then
      insert into public.baby_caregivers (baby_id, user_id, role, can_write)
      values (baby_payload ->> 'id', caller_id, 'owner', true)
      on conflict (baby_id, user_id) do nothing;
    else
      raise exception 'Baby access denied' using errcode = '42501';
    end if;
  end loop;

  select * into result from public.families where id = family_id;
  return result;
end;
$$;
revoke all on function public.apply_family_snapshot(jsonb) from public;
grant execute on function public.apply_family_snapshot(jsonb)
  to anon, authenticated;
-- HEALTH --------------------------------------------------------------------

create table if not exists public.health_events (
  id text primary key,
  owner_id text not null,
  baby_id text not null references public.babies(id) on delete cascade,
  event_type text not null check (
    event_type in ('vaccine', 'pediatricControl', 'growthControl')
  ),
  title text not null,
  description text not null default '',
  starts_at timestamptz not null,
  caregiver_id text,
  status text not null check (status in ('scheduled', 'completed', 'cancelled')),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  updated_by text not null
);
create index if not exists health_events_baby_starts_idx
  on public.health_events (baby_id, starts_at);
create index if not exists health_events_updated_idx
  on public.health_events (updated_at, id);
alter table public.health_events enable row level security;
drop policy if exists "health events select members" on public.health_events;
create policy "health events select members"
  on public.health_events for select to anon, authenticated
  using ((select public.can_access_baby(baby_id)));
drop policy if exists "health events insert members" on public.health_events;
create policy "health events insert members"
  on public.health_events for insert to anon, authenticated
  with check (
    owner_id = auth.jwt() ->> 'sub'
    and updated_by = auth.jwt() ->> 'sub'
    and (select public.can_access_baby(baby_id, true))
  );
drop policy if exists "health events update members" on public.health_events;
create policy "health events update members"
  on public.health_events for update to anon, authenticated
  using ((select public.can_access_baby(baby_id, true)))
  with check (
    updated_by = auth.jwt() ->> 'sub'
    and (select public.can_access_baby(baby_id, true))
  );
grant select, insert, update on public.health_events to anon, authenticated;
create or replace function public.apply_health_event(payload jsonb)
returns public.health_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  target_baby_id text := payload ->> 'baby_id';
  result public.health_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  perform public.bootstrap_baby(target_baby_id, 'Bebé');
  if not public.can_access_baby(target_baby_id, true) then
    raise exception 'Baby write access denied' using errcode = '42501';
  end if;

  insert into public.health_events as target (
    id, owner_id, baby_id, event_type, title, description, starts_at,
    caregiver_id, status, created_at, updated_at, updated_by
  ) values (
    payload ->> 'id',
    caller_id,
    target_baby_id,
    payload ->> 'event_type',
    payload ->> 'title',
    coalesce(payload ->> 'description', ''),
    (payload ->> 'starts_at')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''),
    payload ->> 'status',
    (payload ->> 'created_at')::timestamptz,
    (payload ->> 'updated_at')::timestamptz,
    caller_id
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
grant execute on function public.apply_health_event(jsonb) to anon, authenticated;
-- USER SETTINGS -------------------------------------------------------------

create table if not exists public.user_preferences (
  user_id text primary key,
  theme_mode text not null default 'system'
    check (theme_mode in ('system', 'light', 'dark')),
  high_contrast boolean not null default false,
  personal_reminders boolean not null default true,
  family_activity boolean not null default true,
  daily_summary boolean not null default false,
  reduce_motion boolean not null default false,
  wifi_only boolean not null default false,
  account_name text not null default '',
  account_email text not null default '',
  language text not null default 'Español',
  time_format text not null default '24 horas',
  text_size text not null default 'Predeterminado',
  updated_at timestamptz not null default now()
);
alter table public.user_preferences enable row level security;
drop policy if exists "user preferences own" on public.user_preferences;
create policy "user preferences own"
  on public.user_preferences for all to anon, authenticated
  using (user_id = auth.jwt() ->> 'sub')
  with check (
    (select public.is_bebeapp_firebase_user())
    and user_id = auth.jwt() ->> 'sub'
  );
grant select, insert, update on public.user_preferences to anon, authenticated;
create or replace function public.apply_user_preferences(payload jsonb)
returns public.user_preferences
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  result public.user_preferences;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  insert into public.profiles as target (
    id, email, display_name, created_at, updated_at
  ) values (
    caller_id,
    nullif(trim(coalesce(payload ->> 'account_email', '')), ''),
    nullif(trim(coalesce(payload ->> 'account_name', '')), ''),
    now(),
    (payload ->> 'updated_at')::timestamptz
  )
  on conflict (id) do update set
    email = coalesce(excluded.email, target.email),
    display_name = coalesce(excluded.display_name, target.display_name),
    updated_at = greatest(target.updated_at, excluded.updated_at);

  insert into public.user_preferences as target (
    user_id, theme_mode, high_contrast, personal_reminders, family_activity,
    daily_summary, reduce_motion, wifi_only, account_name, account_email,
    language, time_format, text_size, updated_at
  ) values (
    caller_id,
    coalesce(payload ->> 'theme_mode', 'system'),
    coalesce((payload ->> 'high_contrast')::boolean, false),
    coalesce((payload ->> 'personal_reminders')::boolean, true),
    coalesce((payload ->> 'family_activity')::boolean, true),
    coalesce((payload ->> 'daily_summary')::boolean, false),
    coalesce((payload ->> 'reduce_motion')::boolean, false),
    coalesce((payload ->> 'wifi_only')::boolean, false),
    coalesce(payload ->> 'account_name', ''),
    coalesce(payload ->> 'account_email', ''),
    coalesce(payload ->> 'language', 'Español'),
    coalesce(payload ->> 'time_format', '24 horas'),
    coalesce(payload ->> 'text_size', 'Predeterminado'),
    (payload ->> 'updated_at')::timestamptz
  )
  on conflict (user_id) do update set
    theme_mode = excluded.theme_mode,
    high_contrast = excluded.high_contrast,
    personal_reminders = excluded.personal_reminders,
    family_activity = excluded.family_activity,
    daily_summary = excluded.daily_summary,
    reduce_motion = excluded.reduce_motion,
    wifi_only = excluded.wifi_only,
    account_name = excluded.account_name,
    account_email = excluded.account_email,
    language = excluded.language,
    time_format = excluded.time_format,
    text_size = excluded.text_size,
    updated_at = excluded.updated_at
  where target.updated_at <= excluded.updated_at
  returning * into result;

  if result is null then
    select * into result from public.user_preferences where user_id = caller_id;
  end if;
  return result;
end;
$$;
revoke all on function public.apply_user_preferences(jsonb) from public;
grant execute on function public.apply_user_preferences(jsonb)
  to anon, authenticated;
-- Migration 004 predates family_id and birth_date. Return those canonical
-- identifiers so accepting an invitation creates the same local aggregate
-- instead of inventing a second family id or estimating a birth date.
create or replace function public.lookup_care_invitation(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  caller_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
  caller_phone text := lower(
    regexp_replace(
      coalesce(auth.jwt() ->> 'phone_number', ''),
      '[[:space:]-]',
      '',
      'g'
    )
  );
  invitation public.care_invitations;
  baby public.babies;
  inviter_name text;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  select * into invitation
  from public.care_invitations item
  where item.code = upper(replace(trim(p_code), ' ', ''))
  limit 1;
  if invitation.id is null then
    return jsonb_build_object('found', false, 'failure', 'not_found');
  end if;
  if invitation.invitee_contact <> caller_email
      and invitation.invitee_contact <> caller_phone then
    return jsonb_build_object('found', false, 'failure', 'wrong_account');
  end if;
  if exists (
    select 1 from public.baby_caregivers membership
    where membership.baby_id = invitation.baby_id
      and membership.user_id = caller_id
  ) then
    return jsonb_build_object('found', false, 'failure', 'already_member');
  end if;
  if invitation.status <> 'pending' then
    return jsonb_build_object('found', false, 'failure', invitation.status);
  end if;
  if invitation.expires_at <= now() then
    return jsonb_build_object('found', false, 'failure', 'expired');
  end if;

  select * into baby from public.babies where id = invitation.baby_id;
  select coalesce(nullif(profile.display_name, ''), 'Tu familiar')
    into inviter_name
  from public.profiles profile
  where profile.id = invitation.inviter_id;

  return jsonb_build_object(
    'found', true,
    'id', invitation.id,
    'family_id', baby.family_id,
    'baby_id', invitation.baby_id,
    'baby_name', baby.display_name,
    'baby_birth_date', baby.birth_date,
    'baby_age_label', 'Círculo compartido',
    'inviter_name', coalesce(inviter_name, 'Tu familiar'),
    'inviter_relationship', 'Administrador/a',
    'relationship', invitation.relationship,
    'access_description', invitation.access_description,
    'can_write', invitation.can_write,
    'expires_at', invitation.expires_at
  );
end;
$$;
-- HEALTH NOTIFICATIONS ------------------------------------------------------

create or replace function public.notify_health_activity()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  recipient record;
begin
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
      case when tg_op = 'INSERT' then 'created' else 'updated' end,
      'Salud familiar actualizada',
      'Hay un cambio en los controles o vacunas compartidos.',
      '/health',
      jsonb_build_object(
        'baby_id', new.baby_id,
        'source_table', 'health_events',
        'source_id', new.id,
        'notification_id', gen_random_uuid()::text
      ),
      'health_events',
      new.id,
      new.updated_at
    )
    on conflict (recipient_id, source_table, source_id, source_updated_at)
      do nothing;
  end loop;
  return new;
end;
$$;
drop trigger if exists health_events_notify_care_circle
  on public.health_events;
create trigger health_events_notify_care_circle
after insert or update of updated_at on public.health_events
for each row execute function public.notify_health_activity();
-- Realtime only wakes pull-based services; RLS still filters every payload.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'families', 'babies', 'baby_caregivers', 'health_events', 'user_preferences'
  ] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = table_name
    ) then
      execute format(
        'alter publication supabase_realtime add table public.%I',
        table_name
      );
    end if;
  end loop;
end;
$$;
