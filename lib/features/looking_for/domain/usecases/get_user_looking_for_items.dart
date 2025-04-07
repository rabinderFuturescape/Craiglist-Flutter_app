import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/looking_for_item.dart';
import '../repositories/looking_for_repository.dart';

/// Use case to get "Looking For" items for a specific user
class GetUserLookingForItems implements UseCase<List<LookingForItem>, UserParams> {
  final LookingForRepository repository;

  GetUserLookingForItems(this.repository);

  @override
  Future<Either<Failure, List<LookingForItem>>> call(UserParams params) async {
    return await repository.getUserLookingForItems(params.userId);
  }
}

class UserParams extends Equatable {
  final String userId;

  const UserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
