-- Durable, account-bound invitations for care circles.
-- Run after 202608100003_create_care_circle_notifications.sql.

create table if not exists public.care_invitations (
  id uuid primary key default gen_random_uuid(),
  baby_id text not null references public.babies(id) on delete cascade,
  inviter_id text not null,
  invitee_name text not null default '',
  invitee_contact text not null,
  relationship text not null default 'Cuidador/a',
  access_description text not null default 'Puede acompañar el cuidado',
  can_write boolean not null default true,
  code text not null unique,
  status text not null default 'pending' check (
    status in ('pending', 'accepted', 'rejected', 'revoked')
  ),
  invited_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '7 days'),
  responded_at timestamptz,
  updated_at timestamptz not null default now()
);
create index if not exists care_invitations_contact_idx
  on public.care_invitations (lower(invitee_contact), status, expires_at desc);
create index if not exists care_invitations_sender_idx
  on public.care_invitations (inviter_id, invited_at desc);
create unique index if not exists care_invitations_pending_contact_idx
  on public.care_invitations (baby_id, lower(invitee_contact))
  where status = 'pending';
alter table public.care_invitations enable row level security;
revoke all on public.care_invitations from anon, authenticated;
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
  normalized_contact text := lower(
    regexp_replace(trim(p_contact), '[[:space:]-]', '', 'g')
  );
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
    'baby_id', invitation.baby_id,
    'baby_name', baby.display_name,
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
create or replace function public.accept_care_invitation(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id text := auth.jwt() ->> 'sub';
  lookup jsonb;
  invitation public.care_invitations;
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
  where id = invitation.id;
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
  caller_phone text := lower(
    regexp_replace(
      coalesce(auth.jwt() ->> 'phone_number', ''),
      '[[:space:]-]',
      '',
      'g'
    )
  );
  invitation public.care_invitations;
begin
  select * into invitation
  from public.care_invitations item
  where item.code = upper(replace(trim(p_code), ' ', ''))
    and (
      item.invitee_contact = caller_email
      or item.invitee_contact = caller_phone
    )
    and item.status = 'pending'
  for update;
  if invitation.id is null or caller_id is null then
    raise exception 'Invitation cannot be rejected' using errcode = '22023';
  end if;
  update public.care_invitations
  set status = 'rejected', responded_at = now(), updated_at = now()
  where id = invitation.id;
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
begin
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
  invitation_id uuid;
begin
  update public.care_invitations item
  set status = 'revoked', responded_at = now(), updated_at = now()
  where item.code = upper(replace(trim(p_code), ' ', ''))
    and item.inviter_id = caller_id
    and item.status = 'pending'
  returning item.id into invitation_id;
  if invitation_id is null then
    raise exception 'Invitation cannot be revoked' using errcode = '22023';
  end if;
  return jsonb_build_object('id', invitation_id, 'status', 'revoked');
end;
$$;
revoke all on function public.create_care_invitation(
  text, text, text, text, text, text, boolean, text
) from public;
revoke all on function public.lookup_care_invitation(text) from public;
revoke all on function public.accept_care_invitation(text) from public;
revoke all on function public.reject_care_invitation(text) from public;
revoke all on function public.resend_care_invitation(text, text) from public;
revoke all on function public.revoke_care_invitation(text) from public;
grant execute on function public.create_care_invitation(
  text, text, text, text, text, text, boolean, text
) to anon, authenticated;
grant execute on function public.lookup_care_invitation(text)
  to anon, authenticated;
grant execute on function public.accept_care_invitation(text)
  to anon, authenticated;
grant execute on function public.reject_care_invitation(text)
  to anon, authenticated;
grant execute on function public.resend_care_invitation(text, text)
  to anon, authenticated;
grant execute on function public.revoke_care_invitation(text)
  to anon, authenticated;
