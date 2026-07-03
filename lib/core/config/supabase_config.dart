import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static SupabaseClient? get client =>
      isConfigured ? Supabase.instance.client : null;

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint(
        'Supabase not configured. Pass SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY with --dart-define to enable the '
        'production backend.',
      );
      return;
    }

    await Supabase.initialize(url: url, publishableKey: publishableKey);
    debugPrint('Supabase configured for $url.');
  }
}
