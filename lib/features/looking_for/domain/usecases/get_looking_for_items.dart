import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/looking_for_item.dart';
import '../repositories/looking_for_repository.dart';

/// Use case to get all active "Looking For" items
class GetLookingForItems implements UseCase<List<LookingForItem>, NoParams> {
  final LookingForRepository repository;

  GetLookingForItems(this.repository);

  @override
  Future<Either<Failure, List<LookingForItem>>> call(NoParams params) async {
    return await repository.getLookingForItems();
  }
}
