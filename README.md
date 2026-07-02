# BGN Real Estate Agent App

A Flutter real estate agent CRM and property listing MVP inspired by the BGN Real Estate website experience.

## Packages Added

The project includes the dependency set needed for the planned Flutter + Firebase implementation:

- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `firebase_messaging`, `firebase_analytics`, `firebase_app_check`, `cloud_functions`
- `google_sign_in` for federated authentication
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

## Next Firebase Setup

Run FlutterFire configuration after creating the Firebase project:

```sh
flutterfire configure
```

Then initialize Firebase in `lib/main.dart` before `runApp`.

## Verification

```sh
dart analyze
flutter test
```
