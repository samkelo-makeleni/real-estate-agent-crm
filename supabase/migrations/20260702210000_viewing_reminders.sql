-- Notification preferences and viewing reminder schedule.

alter table public.profiles
add column if not exists push_notifications_enabled boolean not null default false,
add column if not exists viewing_reminder_minutes_before int not null default 60
  check (viewing_reminder_minutes_before between 5 and 1440);

create table if not exists public.appointment_reminders (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  agent_id uuid not null references public.profiles(id) on delete cascade,
  reminder_for timestamptz not null,
  channel text not null default 'push' check (channel in ('push', 'email', 'sms')),
  status text not null default 'scheduled'
    check (status in ('scheduled', 'sent', 'cancelled', 'failed')),
  sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (appointment_id, agent_id)
);

create index if not exists appointment_reminders_agent_time_idx
on public.appointment_reminders (agent_id, reminder_for)
where status = 'scheduled';

create trigger appointment_reminders_set_updated_at
before update on public.appointment_reminders
for each row execute function public.set_updated_at();

alter table public.appointment_reminders enable row level security;

create policy "Agents can manage agency appointment reminders"
on public.appointment_reminders for all
to authenticated
using (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
)
with check (
  agency_id = public.current_agency_id()
  and (agent_id = auth.uid() or public.current_role() = 'admin')
);
