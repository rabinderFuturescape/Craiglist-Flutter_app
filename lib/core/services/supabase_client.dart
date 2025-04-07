import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton class to manage Supabase client instance
class AppSupabaseClient {
  static final AppSupabaseClient _instance = AppSupabaseClient._internal();

  factory AppSupabaseClient() {
    return _instance;
  }

  AppSupabaseClient._internal();

  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _getSupabaseUrl(),
      anonKey: _getSupabaseAnonKey(),
      debug: kDebugMode,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Get Supabase client instance
  static AppSupabaseClient get instance => _instance;

  /// Get Supabase client
  Supabase get client => Supabase.instance;

  /// Get Supabase URL based on environment
  static String _getSupabaseUrl() {
    // For local development with Docker
    if (kDebugMode) {
      return 'http://localhost:8000';
    }

    // For production
    return const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://your-project-id.supabase.co',
    );
  }

  /// Get Supabase anonymous key based on environment
  static String _getSupabaseAnonKey() {
    // For local development with Docker
    if (kDebugMode) {
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE';
    }

    // For production
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'your-anon-key',
    );
  }
}

/// Extension methods for Supabase client
extension SupabaseClientExtension on AppSupabaseClient {
  /// Get Supabase auth client
  GoTrueClient get auth => client.client.auth;

  /// Get Supabase database client
  SupabaseQueryBuilder Function(String) get db => client.client.from;

  /// Get Supabase storage client
  dynamic get storage => client.client.storage;

  /// Get Supabase realtime client
  RealtimeClient get realtime => client.client.realtime;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current session
  Session? get currentSession => auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
