-- Repair legacy agent profiles that were created before agency assignment
-- was enforced. This migration also backfills existing profiles immediately.

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

-- Authenticated agents can call this for their own profile if a future
-- account somehow still lacks an agency.

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
