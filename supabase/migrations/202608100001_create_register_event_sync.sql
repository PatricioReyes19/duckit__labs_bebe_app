-- Offline-first register events for BebéApp.
-- Firebase project connected through Supabase Third-Party Auth: bebeapp-313a4.

create table if not exists public.register_events (
  id text primary key,
  owner_id text not null,
  baby_id text not null,
  event_type text not null check (
    event_type in (
      'feeding',
      'sleep',
      'diaper',
      'clinical_observation',
      'medication',
      'measurement'
    )
  ),
  occurred_at timestamptz not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  caregiver_id text,
  notes text,
  details jsonb not null default '{}'::jsonb,
  schema_version integer not null default 1 check (schema_version > 0)
);
create index if not exists register_events_owner_updated_idx
  on public.register_events (owner_id, updated_at);
create index if not exists register_events_owner_baby_occurred_idx
  on public.register_events (owner_id, baby_id, occurred_at desc)
  where deleted_at is null;
alter table public.register_events enable row level security;
-- Firebase JWTs without a custom role are evaluated as `anon` by Supabase.
-- This predicate keeps that fallback scoped to the exact Firebase project.
create or replace function public.is_bebeapp_firebase_user()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select
    coalesce(auth.jwt() ->> 'sub', '') <> ''
    and auth.jwt() ->> 'iss' =
      'https://securetoken.google.com/bebeapp-313a4'
    and auth.jwt() ->> 'aud' = 'bebeapp-313a4';
$$;
revoke all on function public.is_bebeapp_firebase_user() from public;
grant execute on function public.is_bebeapp_firebase_user()
  to anon, authenticated;
drop policy if exists "register events select own" on public.register_events;
create policy "register events select own"
  on public.register_events
  for select
  to anon, authenticated
  using (
    (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
drop policy if exists "register events insert own" on public.register_events;
create policy "register events insert own"
  on public.register_events
  for insert
  to anon, authenticated
  with check (
    (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
drop policy if exists "register events update own" on public.register_events;
create policy "register events update own"
  on public.register_events
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
grant select, insert, update on public.register_events
  to anon, authenticated;
-- Idempotent last-write-wins mutation. A retry with the same id/timestamp is
-- harmless and an older offline device cannot overwrite a newer mutation.
create or replace function public.apply_register_event(payload jsonb)
returns public.register_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  result public.register_events;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  insert into public.register_events as target (
    id,
    owner_id,
    baby_id,
    event_type,
    occurred_at,
    created_at,
    updated_at,
    deleted_at,
    caregiver_id,
    notes,
    details,
    schema_version
  ) values (
    payload ->> 'id',
    caller_id,
    payload ->> 'baby_id',
    payload ->> 'event_type',
    (payload ->> 'occurred_at')::timestamptz,
    (payload ->> 'created_at')::timestamptz,
    (payload ->> 'updated_at')::timestamptz,
    nullif(payload ->> 'deleted_at', '')::timestamptz,
    nullif(payload ->> 'caregiver_id', ''),
    nullif(payload ->> 'notes', ''),
    coalesce(payload -> 'details', '{}'::jsonb),
    coalesce((payload ->> 'schema_version')::integer, 1)
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
    schema_version = excluded.schema_version
  where
    target.owner_id = caller_id
    and excluded.updated_at >= target.updated_at
  returning * into result;

  if result.id is null then
    select * into result
    from public.register_events
    where id = payload ->> 'id' and owner_id = caller_id;
  end if;

  return result;
end;
$$;
revoke all on function public.apply_register_event(jsonb) from public;
grant execute on function public.apply_register_event(jsonb)
  to anon, authenticated;
insert into storage.buckets (id, name, public)
values ('register-event-media', 'register-event-media', false)
on conflict (id) do update set public = excluded.public;
drop policy if exists "register media select own" on storage.objects;
create policy "register media select own"
  on storage.objects
  for select
  to anon, authenticated
  using (
    bucket_id = 'register-event-media'
    and (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
drop policy if exists "register media insert own" on storage.objects;
create policy "register media insert own"
  on storage.objects
  for insert
  to anon, authenticated
  with check (
    bucket_id = 'register-event-media'
    and (select public.is_bebeapp_firebase_user())
    and (storage.foldername(name))[1] = auth.jwt() ->> 'sub'
  );
drop policy if exists "register media update own" on storage.objects;
create policy "register media update own"
  on storage.objects
  for update
  to anon, authenticated
  using (
    bucket_id = 'register-event-media'
    and (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  )
  with check (
    bucket_id = 'register-event-media'
    and (storage.foldername(name))[1] = auth.jwt() ->> 'sub'
  );
drop policy if exists "register media delete own" on storage.objects;
create policy "register media delete own"
  on storage.objects
  for delete
  to anon, authenticated
  using (
    bucket_id = 'register-event-media'
    and (select public.is_bebeapp_firebase_user())
    and owner_id = auth.jwt() ->> 'sub'
  );
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'register_events'
  ) then
    alter publication supabase_realtime add table public.register_events;
  end if;
end;
$$;
