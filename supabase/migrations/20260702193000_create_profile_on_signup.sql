-- Create an agency/profile record automatically when an agent signs up.
-- Run this after the initial EstatePro schema migration.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  new_agency_id uuid;
  metadata jsonb;
begin
  metadata := coalesce(new.raw_user_meta_data, '{}'::jsonb);

  insert into public.agencies (name)
  values (
    coalesce(
      nullif(metadata->>'agency_name', ''),
      nullif(metadata->>'full_name', '') || ' Agency',
      'EstatePro Agency'
    )
  )
  returning id into new_agency_id;

  insert into public.profiles (
    id,
    agency_id,
    full_name,
    email,
    phone,
    role
  )
  values (
    new.id,
    new_agency_id,
    coalesce(nullif(metadata->>'full_name', ''), split_part(new.email, '@', 1)),
    new.email,
    nullif(metadata->>'phone', ''),
    'agent'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
