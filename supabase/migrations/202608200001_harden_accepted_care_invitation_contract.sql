-- Acceptance must return the membership that was persisted under the lock.
-- The client uses this payload to create its local care-circle context, so a
-- pre-lock lookup must never be allowed to overstate a changed permission.

create or replace function public.accept_care_invitation(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  caller_email text := nullif(lower(trim(coalesce(auth.jwt() ->> 'email', ''))), '');
  caller_name text := coalesce(
    nullif(trim(auth.jwt() ->> 'name'), ''),
    nullif(split_part(coalesce(auth.jwt() ->> 'email', ''), '@', 1), ''),
    'Cuidador/a'
  );
  lookup jsonb;
  invitation public.care_invitations;
  family_name text;
  baby_name text;
  baby_birth_date date;
  inviter_name text;
begin
  lookup := public.lookup_care_invitation(p_code);
  if coalesce((lookup ->> 'found')::boolean, false) is not true then
    raise exception 'Invitation cannot be accepted: %', lookup ->> 'failure'
      using errcode = '22023';
  end if;

  select * into invitation
  from public.care_invitations item
  where item.code = upper(replace(trim(p_code), ' ', ''))
  for update;

  if invitation.id is null
      or invitation.status <> 'pending'
      or invitation.expires_at <= now() then
    raise exception 'Invitation cannot be accepted' using errcode = '22023';
  end if;

  insert into public.baby_caregivers (baby_id, user_id, role, can_write)
  values (
    invitation.baby_id,
    caller_id,
    case when invitation.can_write then 'caregiver' else 'viewer' end,
    invitation.can_write
  )
  on conflict (baby_id, user_id) do update set
    role = excluded.role,
    can_write = excluded.can_write;

  update public.care_invitations
  set status = 'accepted', responded_at = now(), updated_at = now()
  where id = invitation.id
  returning * into invitation;

  perform public.upsert_current_profile(caller_name, caller_email);
  select
    coalesce(nullif(family.name, ''), 'Círculo compartido'),
    coalesce(nullif(baby.display_name, ''), 'Bebé'),
    baby.birth_date
  into family_name, baby_name, baby_birth_date
  from public.babies baby
  join public.families family on family.id = baby.family_id
  where baby.id = invitation.baby_id;
  select coalesce(nullif(profile.display_name, ''), 'Tu familiar')
    into inviter_name
  from public.profiles profile
  where profile.id = invitation.inviter_id;

  insert into public.activity_notifications (
    recipient_id, actor_id, baby_id, kind, title, body, route, payload,
    source_table, source_id, source_updated_at
  ) values (
    invitation.inviter_id,
    caller_id,
    invitation.baby_id,
    'care_invitation_accepted',
    'Invitación aceptada',
    caller_name || ' se unió al círculo de ' || coalesce(baby_name, 'el bebé'),
    '/family/care-circle',
    jsonb_build_object(
      'invitation_code', invitation.code,
      'baby_id', invitation.baby_id,
      'status', 'accepted'
    ),
    'care_invitations',
    invitation.id::text,
    invitation.updated_at
  ) on conflict (
    recipient_id, source_table, source_id, source_updated_at
  ) do nothing;

  return jsonb_build_object(
    'found', true,
    'status', 'accepted',
    'id', invitation.id,
    'family_id', (select family_id from public.babies where id = invitation.baby_id),
    'family_name', family_name,
    'baby_id', invitation.baby_id,
    'baby_name', baby_name,
    'baby_birth_date', baby_birth_date,
    'baby_age_label', 'Círculo compartido',
    'inviter_name', coalesce(inviter_name, 'Tu familiar'),
    'inviter_relationship', 'Administrador/a',
    'relationship', invitation.relationship,
    'access_description', invitation.access_description,
    'can_write', invitation.can_write
  );
end;
$$;
