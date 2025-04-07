import '../models/looking_for_item_model.dart';

/// Interface for the remote data source for the "Looking For" feature
abstract class LookingForRemoteDataSource {
  /// Get all active "Looking For" items
  Future<List<LookingForItemModel>> getLookingForItems();
  
  /// Get "Looking For" items for a specific user
  Future<List<LookingForItemModel>> getUserLookingForItems(String userId);
  
  /// Get a specific "Looking For" item by ID
  Future<LookingForItemModel> getLookingForItemById(String id);
  
  /// Create a new "Looking For" item
  Future<LookingForItemModel> createLookingForItem(LookingForItemModel item);
  
  /// Update an existing "Looking For" item
  Future<LookingForItemModel> updateLookingForItem(LookingForItemModel item);
  
  /// Delete a "Looking For" item
  Future<bool> deleteLookingForItem(String id);
  
  /// Check and update expired items
  Future<int> checkAndUpdateExpiredItems();
}
