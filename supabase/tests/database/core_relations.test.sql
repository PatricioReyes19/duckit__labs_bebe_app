begin;

select plan(16);

select ok(
  exists (
    select 1 from pg_constraint
    where conname = 'push_devices_user_id_fkey'
      and confdeltype = 'c'
  ),
  'push_devices.user_id cascades from profiles'
);
select ok(
  exists (
    select 1 from pg_constraint
    where conname = 'user_preferences_user_id_fkey'
      and confdeltype = 'c'
  ),
  'user_preferences.user_id cascades from profiles'
);
select ok(
  exists (
    select 1 from pg_constraint
    where conname = 'baby_caregivers_user_id_fkey'
      and confdeltype = 'c'
  ),
  'baby_caregivers.user_id cascades from profiles'
);
select ok(
  exists (
    select 1 from pg_constraint
    where conname = 'register_events_baby_id_fkey'
      and confdeltype = 'c'
  ),
  'register_events belongs to Baby'
);
select ok(
  exists (
    select 1 from pg_constraint
    where conname = 'agenda_events_baby_id_fkey'
      and confdeltype = 'c'
  ),
  'agenda_events belongs to Baby'
);
select ok(
  exists (
    select 1 from pg_constraint
    where conname = 'agenda_events_source_register_event_id_fkey'
      and confdeltype = 'n'
  ),
  'agenda source uses ON DELETE SET NULL'
);
select ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'register_events'
      and policyname = 'register events select care circle'
      and qual like '%can_access_baby%'
  ),
  'register SELECT is authorized by Baby membership'
);
select ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'agenda_events'
      and policyname = 'agenda events select care circle'
      and qual like '%can_access_baby%'
  ),
  'agenda SELECT is authorized by Baby membership'
);
select unlike(
  pg_get_functiondef('public.apply_register_event(jsonb)'::regprocedure),
  'bootstrap_baby',
  'register RPC cannot manufacture a Baby'
);
select unlike(
  pg_get_functiondef('public.apply_agenda_event(jsonb)'::regprocedure),
  'bootstrap_baby',
  'agenda RPC cannot manufacture a Baby'
);
select unlike(
  pg_get_functiondef('public.apply_health_event(jsonb)'::regprocedure),
  'bootstrap_baby',
  'health RPC cannot manufacture a Baby'
);

select ok(
  to_regclass('public.agenda_events_updated_id_idx') is not null,
  'agenda delta pull has a stable updated_at + id index'
);
select like(
  (select with_check from pg_policies
   where schemaname = 'public' and tablename = 'register_events'
     and policyname = 'register events insert care circle'),
  '%SELECT auth.jwt() AS jwt%',
  'register INSERT evaluates auth.jwt once per statement'
);
select like(
  (select with_check from pg_policies
   where schemaname = 'public' and tablename = 'register_events'
     and policyname = 'register events update care circle'),
  '%SELECT auth.jwt() AS jwt%',
  'register UPDATE evaluates auth.jwt once per statement'
);
select like(
  (select with_check from pg_policies
   where schemaname = 'public' and tablename = 'agenda_events'
     and policyname = 'agenda events insert care circle'),
  '%SELECT auth.jwt() AS jwt%',
  'agenda INSERT evaluates auth.jwt once per statement'
);
select like(
  (select with_check from pg_policies
   where schemaname = 'public' and tablename = 'agenda_events'
     and policyname = 'agenda events update care circle'),
  '%SELECT auth.jwt() AS jwt%',
  'agenda UPDATE evaluates auth.jwt once per statement'
);

select * from finish();
rollback;
