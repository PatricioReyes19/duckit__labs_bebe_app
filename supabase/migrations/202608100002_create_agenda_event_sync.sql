-- Offline-first agenda events. Register-derived medication doses use a stable
-- source_register_event_id and deterministic id to avoid duplicates.

create table if not exists public.agenda_events (
  id text primary key,
  owner_id text not null,
  baby_id text not null,
  category text not null check (
    category in ('vaccines', 'controls', 'medication', 'exams')
  ),
  title text not null,
  description text not null default '',
  starts_at timestamptz not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  caregiver_id text,
  source_register_event_id text
);
create index if not exists agenda_events_owner_updated_idx
  on public.agenda_events (owner_id, updated_at);
create index if not exists agenda_events_owner_baby_starts_idx
  on public.agenda_events (owner_id, baby_id, starts_at)
  where deleted_at is null;
create index if not exists agenda_events_source_register_idx
  on public.agenda_events (owner_id, source_register_event_id)
  where source_register_event_id is not null;
alter table public.agenda_events enable row level security;
drop policy if exists "agenda events select own" on public.agenda_events;
create policy "agenda events select own"
  on public.agenda_events
  for select
  to anon, authenticated
  using (
    (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
drop policy if exists "agenda events insert own" on public.agenda_events;
create policy "agenda events insert own"
  on public.agenda_events
  for insert
  to anon, authenticated
  with check (
    (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
drop policy if exists "agenda events update own" on public.agenda_events;
create policy "agenda events update own"
  on public.agenda_events
  for update
  to anon, authenticated
  using (
    (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  )
  with check (
    (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
grant select, insert, update on public.agenda_events to anon, authenticated;
create or replace function public.apply_agenda_event(payload jsonb)
returns public.agenda_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  result public.agenda_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  insert into public.agenda_events as target (
    id,
    owner_id,
    baby_id,
    category,
    title,
    description,
    starts_at,
    created_at,
    updated_at,
    deleted_at,
    caregiver_id,
    source_register_event_id
  ) values (
    payload ->> 'id',
    caller_id,
    payload ->> 'baby_id',
    payload ->> 'category',
    payload ->> 'title',
    coalesce(payload ->> 'description', ''),
    (payload ->> 'starts_at')::timestamptz,
    (payload ->> 'created_at')::timestamptz,
    (payload ->> 'updated_at')::timestamptz,
    nullif(payload ->> 'deleted_at', '')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''),
    nullif(payload ->> 'source_register_event_id', '')
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
    source_register_event_id = excluded.source_register_event_id
  where
    target.owner_id = caller_id
    and excluded.updated_at >= target.updated_at
  returning * into result;

  if result.id is null then
    select * into result
    from public.agenda_events
    where id = payload ->> 'id' and owner_id = caller_id;
  end if;

  return result;
end;
$$;
revoke all on function public.apply_agenda_event(jsonb) from public;
grant execute on function public.apply_agenda_event(jsonb)
  to anon, authenticated;
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'agenda_events'
  ) then
    alter publication supabase_realtime add table public.agenda_events;
  end if;
end;
$$;
