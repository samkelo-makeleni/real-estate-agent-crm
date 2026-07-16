-- Harden property media policies for authenticated uploads.
-- This keeps uploads scoped to an agent-owned top-level folder:
--   {auth.uid()}/property-images/{filename}
--   {auth.uid()}/property-videos/{filename}

insert into storage.buckets (id, name, public)
values ('property-media', 'property-media', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view property media" on storage.objects;
drop policy if exists "Agents can upload property media" on storage.objects;
drop policy if exists "Agents can update own property media" on storage.objects;
drop policy if exists "Agents can delete own property media" on storage.objects;

create policy "Public can view property media"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'property-media');

create policy "Agents can upload property media"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'property-media'
  and owner = auth.uid()
  and name like auth.uid()::text || '/%'
);

create policy "Agents can update own property media"
on storage.objects for update
to authenticated
using (
  bucket_id = 'property-media'
  and owner = auth.uid()
  and name like auth.uid()::text || '/%'
)
with check (
  bucket_id = 'property-media'
  and owner = auth.uid()
  and name like auth.uid()::text || '/%'
);

create policy "Agents can delete own property media"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'property-media'
  and owner = auth.uid()
  and name like auth.uid()::text || '/%'
);
