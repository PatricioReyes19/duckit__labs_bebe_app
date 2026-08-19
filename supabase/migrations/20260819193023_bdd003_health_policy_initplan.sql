-- Keep the existing Health permissions while evaluating the caller JWT once
-- per statement instead of once per row.

drop policy if exists "health events select members" on public.health_events;
create policy "health events select members"
  on public.health_events for select to anon, authenticated
  using ((select public.can_access_baby(baby_id)));

drop policy if exists "health events insert members" on public.health_events;
create policy "health events insert members"
  on public.health_events for insert to anon, authenticated
  with check (
    owner_id = (select auth.jwt() ->> 'sub')
    and updated_by = (select auth.jwt() ->> 'sub')
    and (select public.can_access_baby(baby_id, true))
  );

drop policy if exists "health events update members" on public.health_events;
create policy "health events update members"
  on public.health_events for update to anon, authenticated
  using ((select public.can_access_baby(baby_id, true)))
  with check (
    updated_by = (select auth.jwt() ->> 'sub')
    and (select public.can_access_baby(baby_id, true))
  );

;
