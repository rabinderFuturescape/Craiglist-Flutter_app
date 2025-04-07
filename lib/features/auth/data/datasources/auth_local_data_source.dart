import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<User?> getCachedUser();
  Future<void> cacheUser(User user);
  Future<void> clearCache();
  Future<String> signIn({required String email, required String password});
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String USER_KEY = 'user';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<User?> getCachedUser() async {
    final userJson = sharedPreferences.getString(USER_KEY);
    if (userJson != null) {
      // In a real app, you would parse the JSON and create a User object
      // For now, we'll return a dummy user
      return const User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
      );
    }
    return null;
  }

  @override
  Future<void> cacheUser(User user) async {
    // In a real app, you would convert the User object to JSON
    // For now, we'll just store a dummy string
    await sharedPreferences.setString(USER_KEY, 'dummy_user');
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(USER_KEY);
  }

  @override
  Future<String> signIn(
      {required String email, required String password}) async {
    // In a real app, you would validate against stored credentials
    // For now, we'll just check if the user exists
    final usersJson = sharedPreferences.getString('users') ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;

    if (users.containsKey(email) && users[email]['password'] == password) {
      return users[email]['id'];
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // In a real app, you would store the credentials securely
    // For now, we'll just store a dummy user
    final user = User(
      id: DateTime.now().toString(),
      email: email,
      name: name,
    );
    await cacheUser(user);
    return user.id;
  }
}
