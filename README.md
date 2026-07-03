# BGN Real Estate Agent App

A Flutter real estate agent CRM and property listing MVP inspired by the BGN Real Estate website experience.

## Packages Added

The project includes the dependency set needed for the Flutter + Supabase implementation:

- `supabase_flutter` for Auth, Postgres queries, and Storage
- `provider` for MVVM-style state management
- `go_router` for scalable app routing
- `image_picker` and `file_picker` for property photo/document uploads
- `intl` and `table_calendar` for appointment dates and calendar views
- `uuid` for stable client-generated IDs
- `cached_network_image` for property listing images
- `url_launcher` for phone, email, and external links
- `flutter_local_notifications` for local notification display
- `shared_preferences` for lightweight local persistence
- `connectivity_plus` for network state awareness
- `permission_handler`, `geolocator`, and `google_maps_flutter` for map and location flows
- `carousel_slider` for property image galleries
- `fl_chart` for dashboard reporting charts
- `share_plus` for sharing property listings

## Supabase Setup

Create a local `.env` from `.env.example`, then run Flutter with:

```sh
flutter run --dart-define-from-file=.env
```

Apply the SQL migrations in `supabase/migrations` in timestamp order. See `docs/SUPABASE_SETUP.md` for the full setup flow.

## Verification

```sh
dart analyze
flutter test
```
