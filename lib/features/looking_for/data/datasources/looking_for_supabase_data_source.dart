import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/looking_for_item.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/supabase_client.dart';
import 'looking_for_remote_data_source.dart';

/// Implementation of LookingForRemoteDataSource using Supabase
class LookingForSupabaseDataSource implements LookingForRemoteDataSource {
  final AppSupabaseClient _supabaseClient;

  LookingForSupabaseDataSource({
    required AppSupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<List<LookingForItem>> getLookingForItems() async {
    try {
      final response = await _supabaseClient.db('looking_for_items')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return (response.data as List)
          .map((json) => LookingForItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LookingForItem> getLookingForItemById(String id) async {
    try {
      final response = await _supabaseClient.db('looking_for_items')
          .select()
          .eq('id', id)
          .single();
      
      if (response.error != null) {
        if (response.error!.message.contains('no rows found')) {
          throw NotFoundException(message: 'Looking for item not found');
        }
        throw ServerException(message: response.error!.message);
      }

      return LookingForItem.fromJson(response.data);
    } on PostgrestException catch (e) {
      if (e.message.contains('no rows found')) {
        throw NotFoundException(message: 'Looking for item not found');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LookingForItem>> getUserLookingForItems(String userId) async {
    try {
      final response = await _supabaseClient.db('looking_for_items')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return (response.data as List)
          .map((json) => LookingForItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LookingForItem> createLookingForItem(LookingForItem item) async {
    try {
      // Check if user is authenticated
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      // Convert item to JSON and add user ID
      final itemJson = item.toJson();
      itemJson['user_id'] = user.id;

      final response = await _supabaseClient.db('looking_for_items')
          .insert(itemJson)
          .select()
          .single();
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return LookingForItem.fromJson(response.data);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LookingForItem> updateLookingForItem(String id, LookingForItem item) async {
    try {
      // Check if user is authenticated
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      // Convert item to JSON and remove id (can't update primary key)
      final itemJson = item.toJson();
      itemJson.remove('id');

      final response = await _supabaseClient.db('looking_for_items')
          .update(itemJson)
          .eq('id', id)
          .eq('user_id', user.id) // Ensure user owns the item
          .select()
          .single();
      
      if (response.error != null) {
        if (response.error!.message.contains('no rows found')) {
          throw NotFoundException(message: 'Looking for item not found or not owned by user');
        }
        throw ServerException(message: response.error!.message);
      }

      return LookingForItem.fromJson(response.data);
    } on PostgrestException catch (e) {
      if (e.message.contains('no rows found')) {
        throw NotFoundException(message: 'Looking for item not found or not owned by user');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> deleteLookingForItem(String id) async {
    try {
      // Check if user is authenticated
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final response = await _supabaseClient.db('looking_for_items')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id); // Ensure user owns the item
      
      if (response.error != null) {
        if (response.error!.message.contains('no rows found')) {
          throw NotFoundException(message: 'Looking for item not found or not owned by user');
        }
        throw ServerException(message: response.error!.message);
      }

      return true;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> checkAndUpdateExpiredItems() async {
    try {
      // Get current date
      final now = DateTime.now().toUtc();
      
      // Find expired items
      final response = await _supabaseClient.db('looking_for_items')
          .update({'is_active': false})
          .lt('expiry_date', now.toIso8601String())
          .eq('is_active', true);
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      // Return count of updated items
      return response.count ?? 0;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
