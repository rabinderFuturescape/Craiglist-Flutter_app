import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/looking_for_item.dart';

/// Repository interface for the "Looking For" feature
abstract class LookingForRepository {
  /// Get all active "Looking For" items
  Future<Either<Failure, List<LookingForItem>>> getLookingForItems();
  
  /// Get "Looking For" items for a specific user
  Future<Either<Failure, List<LookingForItem>>> getUserLookingForItems(String userId);
  
  /// Get a specific "Looking For" item by ID
  Future<Either<Failure, LookingForItem>> getLookingForItemById(String id);
  
  /// Create a new "Looking For" item
  Future<Either<Failure, LookingForItem>> createLookingForItem(LookingForItem item);
  
  /// Update an existing "Looking For" item
  Future<Either<Failure, LookingForItem>> updateLookingForItem(LookingForItem item);
  
  /// Delete a "Looking For" item
  Future<Either<Failure, bool>> deleteLookingForItem(String id);
  
  /// Check and update expired items
  Future<Either<Failure, int>> checkAndUpdateExpiredItems();
}
