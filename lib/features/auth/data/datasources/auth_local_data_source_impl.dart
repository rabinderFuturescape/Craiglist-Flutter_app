import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_USER_KEY = 'CACHED_USER';

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would validate against a backend
    // For now, we'll just check if the user exists in SharedPreferences
    final userJson = sharedPreferences.getString(CACHED_USER_KEY);
    if (userJson != null) {
      final user = User.fromJson(json.decode(userJson));
      if (user.email == email) {
        return user.id;
      }
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Create a new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );

    // Save user to SharedPreferences
    await sharedPreferences.setString(
      CACHED_USER_KEY,
      json.encode(user.toJson()),
    );

    return user.id;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(CACHED_USER_KEY);
  }

  @override
  Future<User?> getCachedUser() async {
    final userJson = sharedPreferences.getString(CACHED_USER_KEY);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  @override
  Future<void> cacheUser(User user) async {
    await sharedPreferences.setString(
      CACHED_USER_KEY,
      json.encode(user.toJson()),
    );
  }
}
