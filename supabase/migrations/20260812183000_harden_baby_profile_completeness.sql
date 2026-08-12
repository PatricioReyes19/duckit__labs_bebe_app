-- Baby is the parent of Register, Agenda and Health. Compatibility RPCs used
-- to create placeholder rows with no family or birth date, which then made
-- every child synchronization ambiguous. Existing invalid rows are kept so a
-- valid local Family snapshot can repair them; all new writes are protected.

alter table public.babies
  drop constraint if exists babies_family_id_required;
alter table public.babies
  add constraint babies_family_id_required
  check (family_id is not null) not valid;

alter table public.babies
  drop constraint if exists babies_display_name_required;
alter table public.babies
  add constraint babies_display_name_required
  check (nullif(btrim(display_name), '') is not null) not valid;

alter table public.babies
  drop constraint if exists babies_birth_date_required;
alter table public.babies
  add constraint babies_birth_date_required
  check (birth_date is not null) not valid;

alter table public.families
  drop constraint if exists families_name_required;
alter table public.families
  add constraint families_name_required
  check (nullif(btrim(name), '') is not null) not valid;

-- A complete local snapshot may repair a compatibility placeholder even when
-- the placeholder received a newer server timestamp from a failed child sync.
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
    target_family_id,
    family_name,
    caller_id,
    incoming_updated_at,
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
    if target_baby_id is null
        or baby_name is null
        or baby_birth_date is null then
      raise exception 'Every Baby requires id, display_name and birth_date'
        using errcode = '22023';
    end if;

    insert into public.babies as target (
      id, family_id, display_name, birth_date, created_by, created_at,
      updated_at, updated_by
    ) values (
      target_baby_id,
      target_family_id,
      baby_name,
      baby_birth_date,
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
        target.created_by = caller_id
        or exists (
          select 1
          from public.baby_caregivers membership
          where membership.baby_id = target.id
            and membership.user_id = caller_id
            and membership.can_write
        )
      )
      and (
        target.family_id = excluded.family_id
        or target.created_by = caller_id
        or exists (
          select 1
          from public.baby_caregivers membership
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
      select 1
      from public.babies baby
      where baby.id = target_baby_id
        and baby.family_id = target_family_id
        and nullif(btrim(baby.display_name), '') is not null
        and baby.birth_date is not null
        and (
          baby.created_by = caller_id
          or public.can_access_baby(baby.id, true)
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

-- Kept for binary compatibility with old clients, but it can no longer create
-- a placeholder Baby. Parent synchronization must happen first.
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

  select * into result
  from public.babies baby
  where baby.id = trim(p_baby_id)
    and baby.family_id is not null
    and nullif(btrim(baby.display_name), '') is not null
    and baby.birth_date is not null;

  if result.id is null then
    raise exception 'Synchronize the complete Baby profile before child data'
      using errcode = '23503';
  end if;
  if not public.can_access_baby(result.id) then
    raise exception 'Baby access denied' using errcode = '42501';
  end if;
  return result;
end;
$$;

-- Invitations reference an already synchronized Baby. They must never create
-- a second or incomplete parent row as a side effect.
create or replace function public.create_care_invitation(
  p_baby_id text,
  p_baby_name text,
  p_invitee_name text,
  p_contact text,
  p_relationship text,
  p_access_description text,
  p_can_write boolean,
  p_code text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  normalized_contact text := case
    when position('@' in trim(p_contact)) > 0 then lower(trim(p_contact))
    else lower(regexp_replace(trim(p_contact), '[[:space:]-]', '', 'g'))
  end;
  normalized_code text := upper(replace(trim(p_code), ' ', ''));
  invitation public.care_invitations;
  recipient_id text;
  inviter_name text;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if nullif(trim(p_baby_id), '') is null
      or nullif(normalized_contact, '') is null
      or nullif(normalized_code, '') is null then
    raise exception 'baby, contact and code are required' using errcode = '22023';
  end if;

  if not exists (
    select 1
    from public.babies baby
    join public.baby_caregivers membership on membership.baby_id = baby.id
    where baby.id = trim(p_baby_id)
      and baby.family_id is not null
      and nullif(btrim(baby.display_name), '') is not null
      and baby.birth_date is not null
      and membership.user_id = caller_id
      and membership.role = 'owner'
  ) then
    raise exception 'Synchronize the complete Baby profile before inviting caregivers'
      using errcode = '23503';
  end if;

  if exists (
    select 1
    from public.care_invitations pending
    where pending.baby_id = trim(p_baby_id)
      and lower(pending.invitee_contact) = normalized_contact
      and pending.status = 'pending'
  ) then
    raise exception 'A pending invitation already exists for this contact'
      using errcode = '23505';
  end if;

  insert into public.care_invitations (
    baby_id,
    inviter_id,
    invitee_name,
    invitee_contact,
    relationship,
    access_description,
    can_write,
    code
  ) values (
    trim(p_baby_id),
    caller_id,
    coalesce(nullif(trim(p_invitee_name), ''), normalized_contact),
    normalized_contact,
    coalesce(nullif(trim(p_relationship), ''), 'Cuidador/a'),
    coalesce(
      nullif(trim(p_access_description), ''),
      'Puede acompañar el cuidado'
    ),
    p_can_write,
    normalized_code
  ) returning * into invitation;

  select profile.id into recipient_id
  from public.profiles profile
  where lower(profile.email) = normalized_contact
  limit 1;
  select coalesce(nullif(profile.display_name, ''), 'Tu familiar')
    into inviter_name
  from public.profiles profile
  where profile.id = caller_id;

  if recipient_id is not null then
    insert into public.activity_notifications (
      recipient_id,
      actor_id,
      baby_id,
      kind,
      title,
      body,
      route,
      payload,
      source_table,
      source_id,
      source_updated_at
    ) values (
      recipient_id,
      caller_id,
      invitation.baby_id,
      'care_invitation',
      'Invitación a un círculo de cuidado',
      coalesce(inviter_name, 'Tu familiar') || ' te invitó a cuidar a ' ||
        coalesce(nullif(trim(p_baby_name), ''), 'un bebé'),
      '/invitation?code=' || invitation.code,
      jsonb_build_object('invitation_code', invitation.code),
      'care_invitations',
      invitation.id::text,
      invitation.updated_at
    ) on conflict do nothing;
  end if;

  return jsonb_build_object(
    'id', invitation.id,
    'code', invitation.code,
    'expires_at', invitation.expires_at
  );
end;
$$;

revoke all on function public.bootstrap_baby(text, text) from public;
grant execute on function public.bootstrap_baby(text, text)
  to anon, authenticated;
revoke all on function public.create_care_invitation(
  text, text, text, text, text, text, boolean, text
) from public;
grant execute on function public.create_care_invitation(
  text, text, text, text, text, text, boolean, text
) to anon, authenticated;

-- Operational preflight. This intentionally does not fabricate a birth date.
-- Run before/after deployment to find profiles that still require local repair.
create or replace function public.incomplete_baby_profiles()
returns table (
  baby_id text,
  missing_family boolean,
  missing_name boolean,
  missing_birth_date boolean
)
language sql
security definer
set search_path = ''
as $$
  select
    baby.id,
    baby.family_id is null,
    nullif(btrim(baby.display_name), '') is null,
    baby.birth_date is null
  from public.babies baby
  where public.can_access_baby(baby.id)
    and (
      baby.family_id is null
      or nullif(btrim(baby.display_name), '') is null
      or baby.birth_date is null
    )
  order by baby.created_at, baby.id;
$$;

revoke all on function public.incomplete_baby_profiles() from public;
grant execute on function public.incomplete_baby_profiles()
  to anon, authenticated;
