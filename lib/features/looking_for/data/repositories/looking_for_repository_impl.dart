import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/looking_for_item.dart';
import '../../domain/repositories/looking_for_repository.dart';
import '../datasources/looking_for_remote_data_source.dart';

/// Implementation of the repository for the "Looking For" feature
class LookingForRepositoryImpl implements LookingForRepository {
  final LookingForRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LookingForRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<LookingForItem>>> getLookingForItems() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteItems = await remoteDataSource.getLookingForItems();
        return Right(remoteItems);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<LookingForItem>>> getUserLookingForItems(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteItems = await remoteDataSource.getUserLookingForItems(userId);
        return Right(remoteItems);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, LookingForItem>> getLookingForItemById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteItem = await remoteDataSource.getLookingForItemById(id);
        return Right(remoteItem);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, LookingForItem>> createLookingForItem(LookingForItem item) async {
    if (await networkInfo.isConnected) {
      try {
        // We need to cast the domain entity to the data model
        final itemModel = item as dynamic;
        final createdItem = await remoteDataSource.createLookingForItem(itemModel);
        return Right(createdItem);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, LookingForItem>> updateLookingForItem(LookingForItem item) async {
    if (await networkInfo.isConnected) {
      try {
        // We need to cast the domain entity to the data model
        final itemModel = item as dynamic;
        final updatedItem = await remoteDataSource.updateLookingForItem(itemModel);
        return Right(updatedItem);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLookingForItem(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteLookingForItem(id);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, int>> checkAndUpdateExpiredItems() async {
    if (await networkInfo.isConnected) {
      try {
        final expiredCount = await remoteDataSource.checkAndUpdateExpiredItems();
        return Right(expiredCount);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
