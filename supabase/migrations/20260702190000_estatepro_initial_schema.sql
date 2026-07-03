-- EstatePro production schema for Supabase/Postgres.
-- Apply this in Supabase SQL editor or with `supabase db push`.

create extension if not exists "pgcrypto";

create type public.user_role as enum ('admin', 'agent', 'viewer');
create type public.property_type as enum ('house', 'apartment', 'land', 'office');
create type public.property_status as enum ('available', 'sold', 'rented', 'pending');
create type public.lead_status as enum (
  'new_lead',
  'contacted',
  'viewing_booked',
  'offer_made',
  'closed'
);
create type public.appointment_status as enum (
  'booked',
  'completed',
  'cancelled',
  'rescheduled'
);
create type public.task_status as enum ('open', 'done', 'cancelled');
create type public.offer_status as enum (
  'draft',
  'submitted',
  'accepted',
  'rejected',
  'withdrawn'
);

create table public.agencies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  registration_number text,
  phone text,
  email text,
  website text,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  agency_id uuid references public.agencies(id) on delete set null,
  full_name text not null,
  email text not null unique,
  phone text,
  role public.user_role not null default 'agent',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.clients (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  assigned_agent_id uuid references public.profiles(id) on delete set null,
  full_name text not null,
  email text,
  phone text,
  preferred_location text,
  budget numeric(14, 2),
  notes text,
  created_at timestamptz not null default now()
);

create table public.properties (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  agent_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  price numeric(14, 2) not null check (price >= 0),
  location text not null,
  type public.property_type not null,
  bedrooms int not null default 0 check (bedrooms >= 0),
  bathrooms int not null default 0 check (bathrooms >= 0),
  parking int not null default 0 check (parking >= 0),
  description text not null default '',
  status public.property_status not null default 'available',
  image_urls text[] not null default '{}',
  video_urls text[] not null default '{}',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.leads (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  agent_id uuid not null references public.profiles(id) on delete restrict,
  property_id uuid references public.properties(id) on delete set null,
  client_id uuid references public.clients(id) on delete set null,
  client_name text not null,
  phone text,
  email text,
  budget numeric(14, 2),
  preferred_location text,
  status public.lead_status not null default 'new_lead',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  agent_id uuid not null references public.profiles(id) on delete restrict,
  property_id uuid references public.properties(id) on delete set null,
  client_id uuid references public.clients(id) on delete set null,
  client_name text not null,
  scheduled_for timestamptz not null,
  status public.appointment_status not null default 'booked',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  assigned_agent_id uuid not null references public.profiles(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  title text not null,
  due_at timestamptz,
  status public.task_status not null default 'open',
  created_at timestamptz not null default now()
);

create table public.notes (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  client_id uuid references public.clients(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table public.offers (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  client_id uuid references public.clients(id) on delete set null,
  agent_id uuid not null references public.profiles(id) on delete restrict,
  amount numeric(14, 2) not null check (amount >= 0),
  status public.offer_status not null default 'draft',
  submitted_at timestamptz,
  created_at timestamptz not null default now()
);

create index properties_agency_status_idx on public.properties (agency_id, status);
create index properties_agent_idx on public.properties (agent_id);
create index leads_agent_status_idx on public.leads (agent_id, status);
create index appointments_agent_time_idx on public.appointments (agent_id, scheduled_for);
create index tasks_agent_status_idx on public.tasks (assigned_agent_id, status);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger properties_set_updated_at
before update on public.properties
for each row execute function public.set_updated_at();

create trigger leads_set_updated_at
before update on public.leads
for each row execute function public.set_updated_at();

create trigger appointments_set_updated_at
before update on public.appointments
for each row execute function public.set_updated_at();

alter table public.agencies enable row level security;
alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.properties enable row level security;
alter table public.leads enable row level security;
alter table public.appointments enable row level security;
alter table public.tasks enable row level security;
alter table public.notes enable row level security;
alter table public.offers enable row level security;

create or replace function public.current_agency_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select agency_id from public.profiles where id = auth.uid()
$$;

create or replace function public.current_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

create policy "Agents can view their agency"
on public.agencies for select
to authenticated
using (id = public.current_agency_id());

create policy "Agents can view agency profiles"
on public.profiles for select
to authenticated
using (agency_id = public.current_agency_id() or id = auth.uid());

create policy "Agents can update own profile"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "Agents can view agency clients"
on public.clients for select
to authenticated
using (agency_id = public.current_agency_id());

create policy "Agents can manage assigned clients"
on public.clients for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (assigned_agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (assigned_agent_id = auth.uid() or public.current_role() = 'admin')
);

create policy "Public can view available properties"
on public.properties for select
to anon, authenticated
using (status = 'available');

create policy "Agents can view agency properties"
on public.properties for select
to authenticated
using (agency_id = public.current_agency_id());

create policy "Agents can manage own properties"
on public.properties for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
);

create policy "Agents can manage agency leads"
on public.leads for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
);

create policy "Agents can manage agency appointments"
on public.appointments for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
);

create policy "Agents can manage assigned tasks"
on public.tasks for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (assigned_agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (assigned_agent_id = auth.uid() or public.current_role() = 'admin')
);

create policy "Agents can manage agency notes"
on public.notes for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (author_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (author_id = auth.uid() or public.current_role() = 'admin')
);

create policy "Agents can manage agency offers"
on public.offers for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
);

insert into storage.buckets (id, name, public)
values
  ('property-media', 'property-media', true),
  ('agent-documents', 'agent-documents', false)
on conflict (id) do nothing;
