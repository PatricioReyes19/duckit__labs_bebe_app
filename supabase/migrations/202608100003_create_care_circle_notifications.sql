-- Shared care circles, durable activity notifications and FCM devices.
-- Run after the register and agenda sync migrations.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id text primary key,
  email text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.babies (
  id text primary key,
  display_name text not null default 'Bebé',
  created_by text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.baby_caregivers (
  baby_id text not null references public.babies(id) on delete cascade,
  user_id text not null,
  role text not null default 'caregiver' check (
    role in ('owner', 'caregiver', 'viewer')
  ),
  can_write boolean not null default true,
  joined_at timestamptz not null default now(),
  primary key (baby_id, user_id)
);

create index if not exists baby_caregivers_user_idx
  on public.baby_caregivers (user_id, baby_id);

alter table public.profiles enable row level security;
alter table public.babies enable row level security;
alter table public.baby_caregivers enable row level security;

create or replace function public.can_access_baby(
  target_baby_id text,
  require_write boolean default false
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.baby_caregivers membership
    where membership.baby_id = target_baby_id
      and membership.user_id = auth.jwt() ->> 'sub'
      and (not require_write or membership.can_write)
  );
$$;

revoke all on function public.can_access_baby(text, boolean) from public;
grant execute on function public.can_access_baby(text, boolean)
  to anon, authenticated;

drop policy if exists "profiles select own" on public.profiles;
create policy "profiles select own"
  on public.profiles for select to anon, authenticated
  using (
    (select public.is_bebeapp_firebase_user())
    and id = auth.jwt() ->> 'sub'
  );

drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own"
  on public.profiles for insert to anon, authenticated
  with check (
    (select public.is_bebeapp_firebase_user())
    and id = auth.jwt() ->> 'sub'
  );

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own"
  on public.profiles for update to anon, authenticated
  using (id = auth.jwt() ->> 'sub')
  with check (id = auth.jwt() ->> 'sub');

drop policy if exists "babies select members" on public.babies;
create policy "babies select members"
  on public.babies for select to anon, authenticated
  using ((select public.can_access_baby(id)));

drop policy if exists "babies insert creator" on public.babies;
create policy "babies insert creator"
  on public.babies for insert to anon, authenticated
  with check (
    (select public.is_bebeapp_firebase_user())
    and created_by = auth.jwt() ->> 'sub'
  );

drop policy if exists "baby caregivers select members"
  on public.baby_caregivers;
create policy "baby caregivers select members"
  on public.baby_caregivers for select to anon, authenticated
  using ((select public.can_access_baby(baby_id)));

drop policy if exists "baby caregivers insert owner"
  on public.baby_caregivers;
create policy "baby caregivers insert owner"
  on public.baby_caregivers for insert to anon, authenticated
  with check (
    exists (
      select 1 from public.babies baby
      where baby.id = baby_id
        and baby.created_by = auth.jwt() ->> 'sub'
    )
  );

drop policy if exists "baby caregivers update owner"
  on public.baby_caregivers;
create policy "baby caregivers update owner"
  on public.baby_caregivers for update to anon, authenticated
  using (
    exists (
      select 1 from public.babies baby
      where baby.id = baby_id
        and baby.created_by = auth.jwt() ->> 'sub'
    )
  )
  with check (
    exists (
      select 1 from public.babies baby
      where baby.id = baby_id
        and baby.created_by = auth.jwt() ->> 'sub'
    )
  );

grant select, insert, update on public.profiles to anon, authenticated;
grant select, insert, update on public.babies to anon, authenticated;
grant select, insert, update on public.baby_caregivers
  to anon, authenticated;

-- Existing owner-only rows become one-member care circles.
insert into public.babies (id, display_name, created_by)
select source.baby_id, 'Bebé', min(source.owner_id)
from (
  select baby_id, owner_id from public.register_events
  union all
  select baby_id, owner_id from public.agenda_events
) source
group by source.baby_id
on conflict (id) do nothing;

insert into public.baby_caregivers (baby_id, user_id, role, can_write)
select distinct source.baby_id, source.owner_id, 'owner', true
from (
  select baby_id, owner_id from public.register_events
  union all
  select baby_id, owner_id from public.agenda_events
) source
on conflict (baby_id, user_id) do nothing;

create or replace function public.bootstrap_baby(
  p_baby_id text,
  p_display_name text default 'Bebé'
)
returns public.babies
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  result public.babies;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if nullif(trim(p_baby_id), '') is null then
    raise exception 'baby_id is required' using errcode = '22023';
  end if;

  insert into public.babies (id, display_name, created_by)
  values (p_baby_id, coalesce(nullif(trim(p_display_name), ''), 'Bebé'), caller_id)
  on conflict (id) do nothing;

  insert into public.baby_caregivers (baby_id, user_id, role, can_write)
  select p_baby_id, caller_id, 'owner', true
  from public.babies baby
  where baby.id = p_baby_id and baby.created_by = caller_id
  on conflict (baby_id, user_id) do nothing;

  if not public.can_access_baby(p_baby_id) then
    raise exception 'Baby access denied' using errcode = '42501';
  end if;

  select * into result from public.babies where id = p_baby_id;
  return result;
end;
$$;

revoke all on function public.bootstrap_baby(text, text) from public;
grant execute on function public.bootstrap_baby(text, text)
  to anon, authenticated;

create or replace function public.add_baby_caregiver(
  p_baby_id text,
  p_user_id text,
  p_role text default 'caregiver',
  p_can_write boolean default true
)
returns public.baby_caregivers
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  result public.baby_caregivers;
begin
  if not exists (
    select 1 from public.babies baby
    where baby.id = p_baby_id and baby.created_by = caller_id
  ) then
    raise exception 'Only the care-circle owner can add caregivers'
      using errcode = '42501';
  end if;
  if p_role not in ('owner', 'caregiver', 'viewer') then
    raise exception 'Invalid caregiver role' using errcode = '22023';
  end if;

  insert into public.baby_caregivers (baby_id, user_id, role, can_write)
  values (p_baby_id, p_user_id, p_role, p_can_write)
  on conflict (baby_id, user_id) do update set
    role = excluded.role,
    can_write = excluded.can_write
  returning * into result;
  return result;
end;
$$;

revoke all on function public.add_baby_caregiver(text, text, text, boolean)
  from public;
grant execute on function public.add_baby_caregiver(text, text, text, boolean)
  to anon, authenticated;

alter table public.register_events
  add column if not exists updated_by text;
update public.register_events set updated_by = owner_id where updated_by is null;
alter table public.register_events alter column updated_by set not null;

alter table public.agenda_events
  add column if not exists updated_by text;
update public.agenda_events set updated_by = owner_id where updated_by is null;
alter table public.agenda_events alter column updated_by set not null;

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

create or replace function public.apply_register_event(payload jsonb)
returns public.register_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  target_baby_id text := payload ->> 'baby_id';
  result public.register_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  perform public.bootstrap_baby(
    target_baby_id,
    coalesce(payload ->> 'baby_name', 'Bebé')
  );
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
    baby_id = excluded.baby_id,
    event_type = excluded.event_type,
    occurred_at = excluded.occurred_at,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at,
    caregiver_id = excluded.caregiver_id,
    notes = excluded.notes,
    details = excluded.details,
    schema_version = excluded.schema_version,
    updated_by = caller_id
  where
    public.can_access_baby(target.baby_id, true)
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
  target_baby_id text := payload ->> 'baby_id';
  result public.agenda_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  perform public.bootstrap_baby(
    target_baby_id,
    coalesce(payload ->> 'baby_name', 'Bebé')
  );
  if not public.can_access_baby(target_baby_id, true) then
    raise exception 'Write access denied' using errcode = '42501';
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
    nullif(payload ->> 'caregiver_id', ''),
    nullif(payload ->> 'source_register_event_id', ''),
    caller_id
  )
  on conflict (id) do update set
    baby_id = excluded.baby_id,
    category = excluded.category,
    title = excluded.title,
    description = excluded.description,
    starts_at = excluded.starts_at,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at,
    caregiver_id = excluded.caregiver_id,
    source_register_event_id = excluded.source_register_event_id,
    updated_by = caller_id
  where
    public.can_access_baby(target.baby_id, true)
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

-- Media is grouped by baby id so every authorized caregiver can read it.
drop policy if exists "register media select own" on storage.objects;
drop policy if exists "register media insert own" on storage.objects;
drop policy if exists "register media update own" on storage.objects;
drop policy if exists "register media delete own" on storage.objects;
drop policy if exists "register media select care circle" on storage.objects;
drop policy if exists "register media insert care circle" on storage.objects;
drop policy if exists "register media update care circle" on storage.objects;
drop policy if exists "register media delete care circle" on storage.objects;

create policy "register media select care circle"
  on storage.objects for select to anon, authenticated
  using (
    bucket_id = 'register-event-media'
    and (select public.can_access_baby((storage.foldername(name))[1]))
  );
create policy "register media insert care circle"
  on storage.objects for insert to anon, authenticated
  with check (
    bucket_id = 'register-event-media'
    and (select public.can_access_baby((storage.foldername(name))[1], true))
  );
create policy "register media update care circle"
  on storage.objects for update to anon, authenticated
  using (
    bucket_id = 'register-event-media'
    and (select public.can_access_baby((storage.foldername(name))[1], true))
  )
  with check (
    bucket_id = 'register-event-media'
    and (select public.can_access_baby((storage.foldername(name))[1], true))
  );
create policy "register media delete care circle"
  on storage.objects for delete to anon, authenticated
  using (
    bucket_id = 'register-event-media'
    and (select public.can_access_baby((storage.foldername(name))[1], true))
  );

create table if not exists public.push_devices (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  token text not null unique,
  platform text not null,
  enabled boolean not null default true,
  updated_at timestamptz not null default now()
);
create index if not exists push_devices_user_enabled_idx
  on public.push_devices (user_id, enabled);
alter table public.push_devices enable row level security;

drop policy if exists "push devices own" on public.push_devices;
create policy "push devices own"
  on public.push_devices for select to anon, authenticated
  using (user_id = auth.jwt() ->> 'sub');
drop policy if exists "push devices delete own" on public.push_devices;
create policy "push devices delete own"
  on public.push_devices for delete to anon, authenticated
  using (user_id = auth.jwt() ->> 'sub');
grant select, delete on public.push_devices to anon, authenticated;

create or replace function public.register_push_device(
  p_token text,
  p_platform text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if nullif(trim(p_token), '') is null then
    raise exception 'token is required' using errcode = '22023';
  end if;
  insert into public.push_devices (user_id, token, platform, enabled, updated_at)
  values (caller_id, p_token, p_platform, true, now())
  on conflict (token) do update set
    user_id = caller_id,
    platform = excluded.platform,
    enabled = true,
    updated_at = now();
end;
$$;

create or replace function public.unregister_push_device(p_token text)
returns void
language sql
security invoker
set search_path = ''
as $$
  delete from public.push_devices
  where token = p_token and user_id = auth.jwt() ->> 'sub';
$$;

revoke all on function public.register_push_device(text, text) from public;
revoke all on function public.unregister_push_device(text) from public;
grant execute on function public.register_push_device(text, text)
  to anon, authenticated;
grant execute on function public.unregister_push_device(text)
  to anon, authenticated;

create table if not exists public.activity_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id text not null,
  actor_id text not null,
  baby_id text not null references public.babies(id) on delete cascade,
  kind text not null,
  title text not null,
  body text not null,
  route text not null default '/notifications',
  payload jsonb not null default '{}'::jsonb,
  source_table text not null,
  source_id text not null,
  source_updated_at timestamptz not null,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  unique (recipient_id, source_table, source_id, source_updated_at)
);
create index if not exists activity_notifications_recipient_idx
  on public.activity_notifications (recipient_id, created_at desc);
alter table public.activity_notifications enable row level security;

drop policy if exists "activity notifications select recipient"
  on public.activity_notifications;
create policy "activity notifications select recipient"
  on public.activity_notifications for select to anon, authenticated
  using (recipient_id = auth.jwt() ->> 'sub');
drop policy if exists "activity notifications update recipient"
  on public.activity_notifications;
create policy "activity notifications update recipient"
  on public.activity_notifications for update to anon, authenticated
  using (recipient_id = auth.jwt() ->> 'sub')
  with check (recipient_id = auth.jwt() ->> 'sub');
grant select, update on public.activity_notifications to anon, authenticated;

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
begin
  notification_kind := case
    when new.deleted_at is not null then 'deleted'
    when tg_op = 'INSERT' then 'created'
    else 'updated'
  end;
  notification_title := case tg_table_name
    when 'agenda_events' then 'Agenda familiar actualizada'
    else 'Nuevo registro del bebé'
  end;
  notification_body := case
    when new.deleted_at is not null then 'Un cuidador eliminó un elemento.'
    when tg_table_name = 'agenda_events' then 'Hay un cambio en la agenda compartida.'
    else 'Hay nueva actividad en el historial compartido.'
  end;

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
      '/notifications',
      jsonb_build_object(
        'baby_id', new.baby_id,
        'source_table', tg_table_name,
        'source_id', new.id,
        'kind', notification_kind
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

drop trigger if exists register_events_notify_care_circle
  on public.register_events;
create trigger register_events_notify_care_circle
after insert or update of updated_at on public.register_events
for each row execute function public.notify_care_circle_activity();

drop trigger if exists agenda_events_notify_care_circle
  on public.agenda_events;
create trigger agenda_events_notify_care_circle
after insert or update of updated_at on public.agenda_events
for each row execute function public.notify_care_circle_activity();

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'activity_notifications'
  ) then
    alter publication supabase_realtime
      add table public.activity_notifications;
  end if;
end;
$$;
