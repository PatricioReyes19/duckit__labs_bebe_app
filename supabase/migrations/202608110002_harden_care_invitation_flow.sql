-- Complete the account-bound invitation lifecycle.
-- Run after 202608110001_complete_core_data_sync.sql.

create or replace function public.notify_pending_care_invitations_for_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  invitation record;
begin
  if nullif(lower(trim(coalesce(new.email, ''))), '') is null then
    return new;
  end if;

  for invitation in
    select
      item.id,
      item.code,
      item.baby_id,
      item.inviter_id,
      item.updated_at,
      coalesce(nullif(inviter.display_name, ''), 'Tu familiar') as inviter_name,
      coalesce(nullif(baby.display_name, ''), 'un bebé') as baby_name
    from public.care_invitations item
    join public.babies baby on baby.id = item.baby_id
    left join public.profiles inviter on inviter.id = item.inviter_id
    where lower(item.invitee_contact) = lower(trim(new.email))
      and item.status = 'pending'
      and item.expires_at > now()
  loop
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
      new.id,
      invitation.inviter_id,
      invitation.baby_id,
      'care_invitation',
      'Invitación a un círculo de cuidado',
      invitation.inviter_name || ' te invitó a cuidar a ' ||
        invitation.baby_name,
      '/invitation?code=' || invitation.code,
      jsonb_build_object(
        'invitation_code', invitation.code,
        'baby_id', invitation.baby_id
      ),
      'care_invitations',
      invitation.id::text,
      invitation.updated_at
    ) on conflict (
      recipient_id, source_table, source_id, source_updated_at
    ) do nothing;
  end loop;

  return new;
end;
$$;

drop trigger if exists profiles_notify_pending_care_invitations
  on public.profiles;
create trigger profiles_notify_pending_care_invitations
after insert or update of email on public.profiles
for each row execute function public.notify_pending_care_invitations_for_profile();

-- Email addresses may legitimately contain hyphens. Only phone contacts use
-- whitespace/hyphen stripping; otherwise lookup would reject the same account.
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

  insert into public.babies (id, display_name, created_by)
  values (
    trim(p_baby_id),
    coalesce(nullif(trim(p_baby_name), ''), 'Bebé'),
    caller_id
  )
  on conflict (id) do nothing;

  insert into public.baby_caregivers (baby_id, user_id, role, can_write)
  select trim(p_baby_id), caller_id, 'owner', true
  from public.babies baby
  where baby.id = trim(p_baby_id) and baby.created_by = caller_id
  on conflict (baby_id, user_id) do nothing;

  if not exists (
    select 1
    from public.baby_caregivers membership
    where membership.baby_id = trim(p_baby_id)
      and membership.user_id = caller_id
      and membership.role = 'owner'
  ) then
    raise exception 'Only the care-circle owner can invite caregivers'
      using errcode = '42501';
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

create or replace function public.upsert_current_profile(
  p_display_name text default null,
  p_email text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  jwt_email text := nullif(lower(trim(coalesce(auth.jwt() ->> 'email', ''))), '');
  requested_email text := nullif(lower(trim(coalesce(p_email, ''))), '');
  resolved_email text;
  resolved_name text;
  result public.profiles;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if jwt_email is not null
      and requested_email is not null
      and jwt_email <> requested_email then
    raise exception 'Profile email must match the authenticated account'
      using errcode = '42501';
  end if;

  resolved_email := coalesce(jwt_email, requested_email);
  resolved_name := coalesce(
    nullif(trim(p_display_name), ''),
    nullif(trim(auth.jwt() ->> 'name'), ''),
    nullif(split_part(coalesce(resolved_email, ''), '@', 1), ''),
    'Cuidador/a'
  );

  insert into public.profiles as target (
    id, email, display_name, created_at, updated_at
  ) values (
    caller_id, resolved_email, resolved_name, now(), now()
  )
  on conflict (id) do update set
    email = coalesce(excluded.email, target.email),
    display_name = coalesce(excluded.display_name, target.display_name),
    updated_at = now()
  returning * into result;

  return to_jsonb(result);
end;
$$;

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
  baby_name text;
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
  select coalesce(nullif(display_name, ''), 'el bebé') into baby_name
  from public.babies where id = invitation.baby_id;

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

  return lookup || jsonb_build_object('status', 'accepted');
end;
$$;

create or replace function public.reject_care_invitation(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  caller_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
  caller_phone text := lower(regexp_replace(
    coalesce(auth.jwt() ->> 'phone_number', ''), '[[:space:]-]', '', 'g'
  ));
  caller_name text := coalesce(
    nullif(trim(auth.jwt() ->> 'name'), ''),
    nullif(split_part(coalesce(auth.jwt() ->> 'email', ''), '@', 1), ''),
    'La persona invitada'
  );
  invitation public.care_invitations;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  update public.care_invitations item
  set status = 'rejected', responded_at = now(), updated_at = now()
  where item.code = upper(replace(trim(p_code), ' ', ''))
    and (item.invitee_contact = caller_email or item.invitee_contact = caller_phone)
    and item.status = 'pending'
  returning * into invitation;
  if invitation.id is null then
    raise exception 'Invitation cannot be rejected' using errcode = '22023';
  end if;

  perform public.upsert_current_profile(caller_name, caller_email);
  insert into public.activity_notifications (
    recipient_id, actor_id, baby_id, kind, title, body, route, payload,
    source_table, source_id, source_updated_at
  ) values (
    invitation.inviter_id,
    caller_id,
    invitation.baby_id,
    'care_invitation_rejected',
    'Invitación rechazada',
    caller_name || ' rechazó la invitación al círculo familiar.',
    '/family/care-circle',
    jsonb_build_object(
      'invitation_code', invitation.code,
      'baby_id', invitation.baby_id,
      'status', 'rejected'
    ),
    'care_invitations',
    invitation.id::text,
    invitation.updated_at
  ) on conflict (
    recipient_id, source_table, source_id, source_updated_at
  ) do nothing;

  return jsonb_build_object('id', invitation.id, 'status', 'rejected');
end;
$$;

create or replace function public.resend_care_invitation(
  p_code text,
  p_new_code text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  invitation public.care_invitations;
  recipient_id text;
  inviter_name text;
  baby_name text;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  update public.care_invitations item
  set code = upper(replace(trim(p_new_code), ' ', '')),
      invited_at = now(),
      expires_at = now() + interval '7 days',
      updated_at = now()
  where item.code = upper(replace(trim(p_code), ' ', ''))
    and item.inviter_id = caller_id
    and item.status = 'pending'
  returning * into invitation;
  if invitation.id is null then
    raise exception 'Invitation cannot be resent' using errcode = '22023';
  end if;

  select id into recipient_id from public.profiles
  where lower(email) = lower(invitation.invitee_contact) limit 1;
  select coalesce(nullif(display_name, ''), 'Tu familiar') into inviter_name
  from public.profiles where id = caller_id;
  select coalesce(nullif(display_name, ''), 'un bebé') into baby_name
  from public.babies where id = invitation.baby_id;

  if recipient_id is not null then
    insert into public.activity_notifications (
      recipient_id, actor_id, baby_id, kind, title, body, route, payload,
      source_table, source_id, source_updated_at
    ) values (
      recipient_id,
      caller_id,
      invitation.baby_id,
      'care_invitation',
      'Invitación reenviada',
      coalesce(inviter_name, 'Tu familiar') || ' te invitó a cuidar a ' ||
        coalesce(baby_name, 'un bebé'),
      '/invitation?code=' || invitation.code,
      jsonb_build_object(
        'invitation_code', invitation.code,
        'baby_id', invitation.baby_id
      ),
      'care_invitations',
      invitation.id::text,
      invitation.updated_at
    ) on conflict (
      recipient_id, source_table, source_id, source_updated_at
    ) do nothing;
  end if;

  return jsonb_build_object(
    'id', invitation.id,
    'code', invitation.code,
    'expires_at', invitation.expires_at
  );
end;
$$;

create or replace function public.revoke_care_invitation(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  invitation public.care_invitations;
  recipient_id text;
begin
  if caller_id is null or not public.is_bebeapp_firebase_user() then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  update public.care_invitations item
  set status = 'revoked', responded_at = now(), updated_at = now()
  where item.code = upper(replace(trim(p_code), ' ', ''))
    and item.inviter_id = caller_id
    and item.status = 'pending'
  returning * into invitation;
  if invitation.id is null then
    raise exception 'Invitation cannot be revoked' using errcode = '22023';
  end if;

  select id into recipient_id from public.profiles
  where lower(email) = lower(invitation.invitee_contact) limit 1;
  if recipient_id is not null then
    insert into public.activity_notifications (
      recipient_id, actor_id, baby_id, kind, title, body, route, payload,
      source_table, source_id, source_updated_at
    ) values (
      recipient_id,
      caller_id,
      invitation.baby_id,
      'care_invitation_revoked',
      'Invitación cancelada',
      'La invitación al círculo familiar ya no está disponible.',
      '/notifications',
      jsonb_build_object(
        'invitation_code', invitation.code,
        'baby_id', invitation.baby_id,
        'status', 'revoked'
      ),
      'care_invitations',
      invitation.id::text,
      invitation.updated_at
    ) on conflict (
      recipient_id, source_table, source_id, source_updated_at
    ) do nothing;
  end if;

  return jsonb_build_object('id', invitation.id, 'status', 'revoked');
end;
$$;

revoke all on function public.upsert_current_profile(text, text) from public;
grant execute on function public.upsert_current_profile(text, text)
  to anon, authenticated;

revoke all on function public.accept_care_invitation(text) from public;
revoke all on function public.reject_care_invitation(text) from public;
revoke all on function public.resend_care_invitation(text, text) from public;
revoke all on function public.revoke_care_invitation(text) from public;
grant execute on function public.accept_care_invitation(text)
  to anon, authenticated;
grant execute on function public.reject_care_invitation(text)
  to anon, authenticated;
grant execute on function public.resend_care_invitation(text, text)
  to anon, authenticated;
grant execute on function public.revoke_care_invitation(text)
  to anon, authenticated;
