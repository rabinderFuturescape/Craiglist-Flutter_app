import 'dart:async';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

/// A service for managing authentication tokens
///
/// This class handles token lifecycle including storage, retrieval,
/// expiration checking, and token refresh.
class TokenManager {
  final SecureStorageService _secureStorage;
  
  // Token expiration buffer (refresh token if less than 5 minutes remaining)
  static const int _tokenExpirationBufferMinutes = 5;
  
  // Timer for token refresh
  Timer? _refreshTimer;
  
  // Stream controller for authentication state changes
  final _authStateController = StreamController<bool>.broadcast();
  
  /// Stream of authentication state changes
  Stream<bool> get authStateChanges => _authStateController.stream;

  TokenManager({
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageService();

  /// Initialize the token manager
  ///
  /// This should be called when the app starts
  Future<void> initialize() async {
    final isAuthenticated = await _secureStorage.isAuthenticated();
    if (isAuthenticated) {
      final expiryTime = await _secureStorage.getTokenExpiryTime();
      if (expiryTime != null) {
        final expiryDateTime = DateTime.parse(expiryTime);
        _scheduleTokenRefresh(expiryDateTime);
      }
    }
  }

  /// Save authentication tokens
  ///
  /// Stores the access token, refresh token, and expiry time
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiryTime,
  }) async {
    await _secureStorage.saveToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _secureStorage.saveTokenExpiryTime(expiryTime.toIso8601String());
    
    _scheduleTokenRefresh(expiryTime);
    _authStateController.add(true);
  }

  /// Get the current access token
  ///
  /// Returns the token if available and not expired, otherwise returns null
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.getToken();
    if (token == null) return null;
    
    final expiryTimeStr = await _secureStorage.getTokenExpiryTime();
    if (expiryTimeStr == null) return token;
    
    final expiryTime = DateTime.parse(expiryTimeStr);
    if (DateTime.now().isAfter(expiryTime)) {
      // Token is expired, try to refresh
      return await refreshToken();
    }
    
    return token;
  }

  /// Check if the current token is valid
  Future<bool> isTokenValid() async {
    final token = await _secureStorage.getToken();
    if (token == null) return false;
    
    final expiryTimeStr = await _secureStorage.getTokenExpiryTime();
    if (expiryTimeStr == null) return true; // No expiry time, assume valid
    
    final expiryTime = DateTime.parse(expiryTimeStr);
    return DateTime.now().isBefore(expiryTime);
  }

  /// Refresh the access token using the refresh token
  ///
  /// Returns the new access token if successful, otherwise null
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return null;
      
      // TODO: Implement actual API call to refresh token
      // For now, we'll simulate a successful refresh
      final newToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      final expiryTime = DateTime.now().add(const Duration(hours: 1));
      
      await _secureStorage.saveToken(newToken);
      await _secureStorage.saveTokenExpiryTime(expiryTime.toIso8601String());
      
      _scheduleTokenRefresh(expiryTime);
      
      return newToken;
    } catch (e) {
      debugPrint('Failed to refresh token: $e');
      return null;
    }
  }

  /// Clear all authentication data
  Future<void> clearTokens() async {
    await _secureStorage.clearAll();
    _cancelRefreshTimer();
    _authStateController.add(false);
  }

  /// Schedule token refresh before it expires
  void _scheduleTokenRefresh(DateTime expiryTime) {
    _cancelRefreshTimer();
    
    final now = DateTime.now();
    final refreshTime = expiryTime.subtract(Duration(minutes: _tokenExpirationBufferMinutes));
    
    if (refreshTime.isAfter(now)) {
      final timeUntilRefresh = refreshTime.difference(now);
      _refreshTimer = Timer(timeUntilRefresh, () async {
        final newToken = await refreshToken();
        if (newToken == null) {
          // Failed to refresh token, clear auth data
          await clearTokens();
        }
      });
    } else if (expiryTime.isAfter(now)) {
      // Less than buffer time but not expired, refresh immediately
      refreshToken();
    } else {
      // Already expired, clear auth data
      clearTokens();
    }
  }

  /// Cancel the token refresh timer
  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Dispose the token manager
  void dispose() {
    _cancelRefreshTimer();
    _authStateController.close();
  }
}
