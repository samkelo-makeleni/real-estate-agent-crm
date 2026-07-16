-- Allow agency admins to manage profile roles for their agency.

create policy "Admins can update agency profiles"
on public.profiles for update
to authenticated
using (
  agency_id = public.current_agency_id()
  and public.current_role() = 'admin'
)
with check (
  agency_id = public.current_agency_id()
  and public.current_role() = 'admin'
);
