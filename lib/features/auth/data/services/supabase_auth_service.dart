import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/authentication_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/supabase_client.dart';

/// Implementation of AuthenticationService using Supabase
class SupabaseAuthService implements AuthenticationService {
  final AppSupabaseClient _supabaseClient;

  SupabaseAuthService({
    required AppSupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<Map<String, String>> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw AuthException(message: 'Failed to sign in');
      }

      final user = response.user;
      if (user == null) {
        throw AuthException(message: 'User not found');
      }

      // Get user profile data
      final profileResponse = await _supabaseClient.db('profiles')
          .select()
          .eq('id', user.id)
          .single();

      String displayName = email;
      String phone = '';

      if (profileResponse.data != null) {
        displayName = profileResponse.data['full_name'] ?? email;
        phone = profileResponse.data['phone'] ?? '';
      }

      return {
        'token': response.session!.accessToken,
        'user_id': user.id,
        'refresh_token': response.session!.refreshToken,
        'displayName': displayName,
        'email': email,
        'phone': phone,
      };
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<Map<String, String>> signUp(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw AuthException(message: 'Failed to sign up');
      }

      final user = response.user;
      if (user == null) {
        throw AuthException(message: 'User not created');
      }

      // Create user profile
      await _supabaseClient.db('profiles').insert({
        'id': user.id,
        'email': email,
        'full_name': email.split('@')[0], // Default name from email
        'created_at': DateTime.now().toIso8601String(),
      });

      return {
        'token': response.session!.accessToken,
        'user_id': user.id,
        'refresh_token': response.session!.refreshToken,
        'displayName': email.split('@')[0],
        'email': email,
        'phone': '',
      };
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _supabaseClient.isAuthenticated;
  }

  @override
  Future<Map<String, String>> getCurrentUser() async {
    try {
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      // Get user profile data
      final profileResponse = await _supabaseClient.db('profiles')
          .select()
          .eq('id', user.id)
          .single();

      String displayName = user.email ?? '';
      String phone = '';

      if (profileResponse.data != null) {
        displayName = profileResponse.data['full_name'] ?? user.email ?? '';
        phone = profileResponse.data['phone'] ?? '';
      }

      return {
        'user_id': user.id,
        'displayName': displayName,
        'email': user.email ?? '',
        'phone': phone,
      };
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<Map<String, String>> updateProfile({
    required String displayName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final updateData = {
        'full_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (phone != null) {
        updateData['phone'] = phone;
      }

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      final response = await _supabaseClient.db('profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return {
        'user_id': user.id,
        'displayName': displayName,
        'email': user.email ?? '',
        'phone': response.data['phone'] ?? '',
        'avatarUrl': response.data['avatar_url'] ?? '',
      };
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final storagePath = 'avatars/${user.id}/$fileName';

      final response = await _supabaseClient.storage
          .from('profiles')
          .upload(storagePath, filePath);

      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      // Get public URL
      final publicUrl = _supabaseClient.storage
          .from('profiles')
          .getPublicUrl(storagePath);

      // Update profile with new avatar URL
      await updateProfile(
        displayName: (await getCurrentUser())['displayName'] ?? '',
        avatarUrl: publicUrl,
      );

      return publicUrl;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }
}
