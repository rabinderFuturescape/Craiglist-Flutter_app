import '../../domain/services/authentication_service.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/token_manager.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AuthenticationServiceImpl implements AuthenticationService {
  final SecureStorageService _secureStorage;
  final TokenManager _tokenManager;

  AuthenticationServiceImpl({
    SecureStorageService? secureStorage,
    TokenManager? tokenManager,
  }) :
    _secureStorage = secureStorage ?? SecureStorageService(),
    _tokenManager = tokenManager ?? TokenManager();

  @override
  Future<Map<String, String>> signIn(String email, String password) async {
    try {
      // In a real implementation, this would make an API call
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      // Create a mock response
      final response = {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': '1',
        'refresh_token': 'mock_refresh_token',
        'displayName': 'John Doe',
        'email': email,
        'phone': '+1 (555) 123-4567',
      };

      // Calculate token expiry (1 hour from now)
      final expiryTime = DateTime.now().add(const Duration(hours: 1));

      // Store the authentication data using TokenManager
      await _tokenManager.saveTokens(
        accessToken: response['token']!,
        refreshToken: response['refresh_token']!,
        expiryTime: expiryTime,
      );

      // Store user ID separately
      await _secureStorage.saveUserId(response['user_id']!);

      // Store user data
      final userData = {
        'id': response['user_id'],
        'email': email,
        'name': response['displayName'],
        'phone': response['phone'],
      };
      await _secureStorage.saveUserData(json.encode(userData));

      return response;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, String>> signUp(String email, String password) async {
    try {
      // In a real implementation, this would make an API call
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      // Create a mock response
      final response = {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': '1',
        'refresh_token': 'mock_refresh_token',
        'displayName': 'New User',
        'email': email,
        'phone': '',
      };

      // Calculate token expiry (1 hour from now)
      final expiryTime = DateTime.now().add(const Duration(hours: 1));

      // Store the authentication data using TokenManager
      await _tokenManager.saveTokens(
        accessToken: response['token']!,
        refreshToken: response['refresh_token']!,
        expiryTime: expiryTime,
      );

      // Store user ID separately
      await _secureStorage.saveUserId(response['user_id']!);

      // Store user data
      final userData = {
        'id': response['user_id'],
        'email': email,
        'name': response['displayName'],
        'phone': response['phone'],
      };
      await _secureStorage.saveUserData(json.encode(userData));

      return response;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut(String token) async {
    try {
      // In a real implementation, this would make an API call to invalidate the token
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay

      // Clear all stored authentication data
      await _tokenManager.clearTokens();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    // Check if we have a valid token using the token manager
    return await _tokenManager.isTokenValid();
  }

  @override
  Future<String?> getToken() async {
    // Retrieve the token from token manager (handles expiration check)
    return await _tokenManager.getAccessToken();
  }

  @override
  Future<String?> refreshToken() async {
    // Use the token manager to refresh the token
    return await _tokenManager.refreshToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.getUserData();
      if (userData != null) {
        final userMap = json.decode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<User?> updateUserProfile(User user) async {
    try {
      // In a real implementation, this would make an API call to update the user profile
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      // Update the stored user data
      await _secureStorage.saveUserData(json.encode(user.toJson()));

      return user;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return null;
    }
  }
}
