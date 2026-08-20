-- BDD-004: immutable immunization records use the existing health-event
-- aggregate and its JSON payload. This migration only adds eligibility facts
-- to the Baby profile and permits the distinct monoclonal-antibody type.

alter table public.babies
  add column if not exists is_premature boolean not null default false,
  add column if not exists lives_in_rapa_nui boolean not null default false,
  add column if not exists has_rsv_risk boolean not null default false;

alter table public.health_events
  drop constraint if exists health_events_event_type_check;
alter table public.health_events
  add constraint health_events_event_type_check check (
    event_type in (
      'vaccine', 'immunization', 'pediatricControl', 'growthControl',
      'consultation'
    )
  );

-- Keep the authoritative family snapshot RPC atomic. A missing field is
-- intentionally preserved on update so clients predating BDD-004 cannot erase
-- clinical eligibility data merely by synchronizing a display-name change.
create or replace function public.apply_family_snapshot(payload jsonb)
returns public.families
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  target_family_id text := nullif(trim(payload ->> 'family_id'), '');
  family_name text := nullif(trim(payload ->> 'family_name'), '');
  incoming_updated_at timestamptz :=
    nullif(payload ->> 'updated_at', '')::timestamptz;
  baby_payload jsonb;
  target_baby_id text;
  baby_name text;
  baby_birth_date timestamptz;
  baby_is_premature boolean;
  baby_lives_in_rapa_nui boolean;
  baby_has_rsv_risk boolean;
  result public.families;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if target_family_id is null
      or family_name is null
      or incoming_updated_at is null then
    raise exception 'family_id, family_name and updated_at are required'
      using errcode = '22023';
  end if;
  if jsonb_typeof(payload -> 'babies') <> 'array'
      or jsonb_array_length(payload -> 'babies') = 0 then
    raise exception 'At least one complete Baby is required'
      using errcode = '22023';
  end if;
  if exists (select 1 from public.families where id = target_family_id)
      and not exists (
        select 1
        from public.families family
        where family.id = target_family_id
          and (
            family.created_by = caller_id
            or exists (
              select 1
              from public.babies baby
              join public.baby_caregivers membership
                on membership.baby_id = baby.id
              where baby.family_id = target_family_id
                and membership.user_id = caller_id
                and membership.can_write
            )
          )
      ) then
    raise exception 'Family write access denied' using errcode = '42501';
  end if;

  insert into public.families as target (
    id, name, created_by, created_at, updated_at
  ) values (
    target_family_id, family_name, caller_id, incoming_updated_at,
    incoming_updated_at
  )
  on conflict (id) do update set
    name = excluded.name,
    updated_at = excluded.updated_at
  where target.updated_at <= excluded.updated_at
    or nullif(btrim(target.name), '') is null;

  for baby_payload in
    select value from jsonb_array_elements(payload -> 'babies')
  loop
    target_baby_id := nullif(trim(baby_payload ->> 'id'), '');
    baby_name := nullif(trim(baby_payload ->> 'display_name'), '');
    baby_birth_date := nullif(baby_payload ->> 'birth_date', '')::timestamptz;
    baby_is_premature := coalesce(
      nullif(baby_payload ->> 'is_premature', '')::boolean, false
    );
    baby_lives_in_rapa_nui := coalesce(
      nullif(baby_payload ->> 'lives_in_rapa_nui', '')::boolean, false
    );
    baby_has_rsv_risk := coalesce(
      nullif(baby_payload ->> 'has_rsv_risk', '')::boolean, false
    );
    if target_baby_id is null
        or baby_name is null
        or baby_birth_date is null then
      raise exception 'Every Baby requires id, display_name and birth_date'
        using errcode = '22023';
    end if;

    insert into public.babies as target (
      id, family_id, display_name, birth_date, is_premature,
      lives_in_rapa_nui, has_rsv_risk, created_by, created_at, updated_at,
      updated_by
    ) values (
      target_baby_id, target_family_id, baby_name, baby_birth_date,
      baby_is_premature, baby_lives_in_rapa_nui, baby_has_rsv_risk,
      caller_id, incoming_updated_at, incoming_updated_at, caller_id
    )
    on conflict (id) do update set
      family_id = excluded.family_id,
      display_name = excluded.display_name,
      birth_date = excluded.birth_date,
      is_premature = case
        when baby_payload ? 'is_premature' then excluded.is_premature
        else target.is_premature
      end,
      lives_in_rapa_nui = case
        when baby_payload ? 'lives_in_rapa_nui' then excluded.lives_in_rapa_nui
        else target.lives_in_rapa_nui
      end,
      has_rsv_risk = case
        when baby_payload ? 'has_rsv_risk' then excluded.has_rsv_risk
        else target.has_rsv_risk
      end,
      updated_at = excluded.updated_at,
      updated_by = excluded.updated_by
    where (
        target.created_by = caller_id
        or exists (
          select 1 from public.baby_caregivers membership
          where membership.baby_id = target.id
            and membership.user_id = caller_id
            and membership.can_write
        )
      )
      and (
        target.family_id = excluded.family_id
        or target.created_by = caller_id
        or exists (
          select 1 from public.baby_caregivers membership
          where membership.baby_id = target.id
            and membership.user_id = caller_id
            and membership.role = 'owner'
        )
      )
      and (
        target.updated_at <= excluded.updated_at
        or target.family_id is null
        or nullif(btrim(target.display_name), '') is null
        or target.birth_date is null
      );

    if exists (
      select 1 from public.babies baby
      where baby.id = target_baby_id
        and baby.family_id = target_family_id
        and nullif(btrim(baby.display_name), '') is not null
        and baby.birth_date is not null
        and (
          baby.created_by = caller_id or public.can_access_baby(baby.id, true)
        )
    ) then
      insert into public.baby_caregivers (baby_id, user_id, role, can_write)
      values (target_baby_id, caller_id, 'owner', true)
      on conflict (baby_id, user_id) do nothing;
    else
      raise exception 'Baby access denied or profile is incomplete'
        using errcode = '42501';
    end if;
  end loop;

  select * into result
  from public.families family
  where family.id = target_family_id;
  return result;
end;
$$;
revoke all on function public.apply_family_snapshot(jsonb) from public;
grant execute on function public.apply_family_snapshot(jsonb)
  to anon, authenticated;
