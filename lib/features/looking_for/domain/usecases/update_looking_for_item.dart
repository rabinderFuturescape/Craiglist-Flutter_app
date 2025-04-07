import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/looking_for_item.dart';
import '../repositories/looking_for_repository.dart';

/// Use case to update an existing "Looking For" item
class UpdateLookingForItem implements UseCase<LookingForItem, UpdateLookingForParams> {
  final LookingForRepository repository;

  UpdateLookingForItem(this.repository);

  @override
  Future<Either<Failure, LookingForItem>> call(UpdateLookingForParams params) async {
    return await repository.updateLookingForItem(params.item);
  }
}

class UpdateLookingForParams extends Equatable {
  final LookingForItem item;

  const UpdateLookingForParams({required this.item});

  @override
  List<Object> get props => [item];
}
