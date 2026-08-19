-- BDD-014: measured delta-query and RLS initialization improvements.
--
-- EXPLAIN (ANALYZE, BUFFERS) on 2026-08-19 showed the Agenda delta pull
-- scanning and sorting all 548 rows (14.026 ms) for a 200-row page. Register
-- had only 39 rows/1.430 ms, so no equivalent index is added there yet.

create index if not exists agenda_events_updated_id_idx
  on public.agenda_events (updated_at, id);

-- `auth.jwt()` is statement-stable. Wrapping it in SELECT lets Postgres create
-- one initPlan instead of evaluating the function once per candidate row.
-- Authorization predicates and roles remain otherwise identical.
alter policy "register events insert care circle"
  on public.register_events
  with check (
    (select public.can_access_baby(baby_id, true))
    and owner_id = (select auth.jwt()) ->> 'sub'
    and updated_by = (select auth.jwt()) ->> 'sub'
  );

alter policy "register events update care circle"
  on public.register_events
  using ((select public.can_access_baby(baby_id, true)))
  with check (
    (select public.can_access_baby(baby_id, true))
    and updated_by = (select auth.jwt()) ->> 'sub'
  );

alter policy "agenda events insert care circle"
  on public.agenda_events
  with check (
    (select public.can_access_baby(baby_id, true))
    and owner_id = (select auth.jwt()) ->> 'sub'
    and updated_by = (select auth.jwt()) ->> 'sub'
  );

alter policy "agenda events update care circle"
  on public.agenda_events
  using ((select public.can_access_baby(baby_id, true)))
  with check (
    (select public.can_access_baby(baby_id, true))
    and updated_by = (select auth.jwt()) ->> 'sub'
  );

;
