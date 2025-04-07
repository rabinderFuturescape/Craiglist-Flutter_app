import '../entities/user.dart';

/// Service responsible for user authentication operations.
abstract class AuthenticationService {
  /// Sign in a user with email and password
  Future<Map<String, String>> signIn(String email, String password);

  /// Sign up a new user with email and password
  Future<Map<String, String>> signUp(String email, String password);

  /// Sign out the currently authenticated user
  Future<void> signOut(String token);

  /// Check if a user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get the current user's token
  /// Returns null if no token is available or if the token is expired
  Future<String?> getToken();

  /// Refresh the current authentication token
  /// Returns a new token if successful, null otherwise
  Future<String?> refreshToken();

  /// Get the current authenticated user
  Future<User?> getCurrentUser();

  /// Update the current user's profile
  Future<User?> updateUserProfile(User user);
}

// Implementation moved to data/services/authentication_service_impl.dart
