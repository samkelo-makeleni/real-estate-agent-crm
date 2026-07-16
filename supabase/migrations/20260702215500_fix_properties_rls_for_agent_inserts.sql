-- Repair property RLS so authenticated agents can publish listings for
-- their own agency, and admins can manage agency listings.

create or replace function public.can_manage_property(
  target_agency_id uuid,
  target_agent_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and profile.agency_id = target_agency_id
      and (
        target_agent_id = auth.uid()
        or profile.role = 'admin'
      )
  )
$$;

drop policy if exists "Agents can insert own agency properties" on public.properties;
drop policy if exists "Agents can update own agency properties" on public.properties;
drop policy if exists "Agents can delete own agency properties" on public.properties;

create policy "Agents can insert own agency properties"
on public.properties for insert
to authenticated
with check (public.can_manage_property(agency_id, agent_id));

create policy "Agents can update own agency properties"
on public.properties for update
to authenticated
using (public.can_manage_property(agency_id, agent_id))
with check (public.can_manage_property(agency_id, agent_id));

create policy "Agents can delete own agency properties"
on public.properties for delete
to authenticated
using (public.can_manage_property(agency_id, agent_id));
