-- One-time repair for "Could not publish property: agent profile is missing an agency"
-- and "new row violates row-level security policy for table properties".
--
-- Run this whole file in the Supabase SQL Editor for the connected project.

do $$
declare
  bgn_agency_id uuid;
begin
  select id
  into bgn_agency_id
  from public.agencies
  where name = 'BGN Real Estate'
  order by created_at
  limit 1;

  if bgn_agency_id is null then
    insert into public.agencies (name, phone, email, website)
    values (
      'BGN Real Estate',
      '+27 (0)73 473 4767',
      'hermanusb@bgnrealestate.co.za',
      'https://www.bgnrealestate.co.za'
    )
    returning id into bgn_agency_id;
  end if;

  update public.profiles
  set agency_id = bgn_agency_id
  where agency_id is null;
end;
$$;

create or replace function public.ensure_current_agent_agency()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_profile public.profiles%rowtype;
  repaired_agency_id uuid;
begin
  select *
  into current_profile
  from public.profiles
  where id = auth.uid();

  if current_profile.id is null then
    raise exception 'Agent profile was not found.';
  end if;

  if current_profile.agency_id is not null then
    return current_profile.agency_id;
  end if;

  select id
  into repaired_agency_id
  from public.agencies
  where name = 'BGN Real Estate'
  order by created_at
  limit 1;

  if repaired_agency_id is null then
    insert into public.agencies (name, phone, email, website)
    values (
      'BGN Real Estate',
      '+27 (0)73 473 4767',
      'hermanusb@bgnrealestate.co.za',
      'https://www.bgnrealestate.co.za'
    )
    returning id into repaired_agency_id;
  end if;

  update public.profiles
  set agency_id = repaired_agency_id
  where id = auth.uid();

  return repaired_agency_id;
end;
$$;

grant execute on function public.ensure_current_agent_agency() to authenticated;

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
