# Supabase Setup

This app uses Supabase Auth, Postgres, Row Level Security, and Supabase Storage for the production backend. When Supabase values are not provided, the Flutter UI can still run with local in-memory fallback data for development.

## 1. Create the Supabase project

1. Create a Supabase project.
2. Open Project Settings > API.
3. Copy the Project URL and publishable key.

## 2. Add local environment values

Create `.env` locally from `.env.example`.

For Flutter run/build commands, pass the values with `--dart-define`:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-public-publishable-key
```

The app logs a message and keeps using local mock services when these values are missing.

## 3. Apply the database schema

Open the Supabase SQL editor and run:

```sql
-- paste contents of:
-- supabase/migrations/20260702190000_estatepro_initial_schema.sql
```

Then run:

```sql
-- paste contents of:
-- supabase/migrations/20260702193000_create_profile_on_signup.sql
```

Then run:

```sql
-- paste contents of:
-- supabase/migrations/20260702200000_storage_object_policies.sql
```

If you previously applied the owner-based storage policies, run the repair migration:

```sql
-- paste contents of:
-- supabase/migrations/20260702203000_fix_property_media_storage_policies.sql
```

This creates the first production tables:

- `agencies`
- `profiles`
- `clients`
- `properties`
- `leads`
- `appointments`
- `tasks`
- `notes`
- `offers`

It also enables Row Level Security, creates initial table policies, creates storage buckets, and allows authenticated agents to upload media to `property-media`.

## 4. Auth and sessions

Agent registration uses Supabase Auth. The signup trigger creates a matching `profiles` row and a default agency row from the auth metadata.

On startup, the app signs out any persisted Supabase session and opens on the sign-in/register screen. Agent-only routes stay guarded until the agent signs in during the current app session.

## 5. Storage

Property photos and videos are uploaded to user-scoped folders in the public `property-media` bucket. The app stores the returned public URLs in `properties.image_urls` and `properties.video_urls`.

Storage policies allow:

- public reads from `property-media`
- authenticated uploads under the signed-in user's folder
- authenticated users to update or delete media under their own folder

Do not use the Supabase service-role key in the Flutter app. Only use the publishable key client-side.
