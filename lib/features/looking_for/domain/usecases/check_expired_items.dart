import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/looking_for_repository.dart';

/// Use case to check and update expired "Looking For" items
class CheckExpiredItems implements UseCase<int, NoParams> {
  final LookingForRepository repository;

  CheckExpiredItems(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.checkAndUpdateExpiredItems();
  }
}
