import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static bool _initialized = false;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    final String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    final String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      // Do not throw during development; allow app to run without insights
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(autoRefreshToken: false, persistSession: false),
    );

    _initialized = true;
  }
}


