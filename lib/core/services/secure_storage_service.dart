import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service for securely storing sensitive data like tokens
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Save user data as JSON string
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  /// Get user data as JSON string
  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Save token expiry time as ISO8601 string
  Future<void> saveTokenExpiryTime(String expiryTime) async {
    await _storage.write(key: _tokenExpiryKey, value: expiryTime);
  }

  /// Get token expiry time as ISO8601 string
  Future<String?> getTokenExpiryTime() async {
    return await _storage.read(key: _tokenExpiryKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    // Check token expiration if available
    final expiryTime = await getTokenExpiryTime();
    if (expiryTime != null) {
      final expiry = DateTime.parse(expiryTime);
      return DateTime.now().isBefore(expiry);
    }

    // If no expiry time is set, just check if token exists
    return true;
  }
}
