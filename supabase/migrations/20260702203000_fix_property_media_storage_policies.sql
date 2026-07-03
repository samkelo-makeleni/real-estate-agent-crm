-- Replace owner-based storage policies with path-based policies.
-- Property media uploads are stored under:
--   {auth.uid()}/property-images/{filename}
--   {auth.uid()}/property-videos/{filename}

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
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Agents can update own property media"
on storage.objects for update
to authenticated
using (
  bucket_id = 'property-media'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'property-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Agents can delete own property media"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'property-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);
