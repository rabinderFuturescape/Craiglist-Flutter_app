import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/looking_for_repository.dart';

/// Use case to delete a "Looking For" item
class DeleteLookingForItem implements UseCase<bool, DeleteLookingForParams> {
  final LookingForRepository repository;

  DeleteLookingForItem(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteLookingForParams params) async {
    return await repository.deleteLookingForItem(params.id);
  }
}

class DeleteLookingForParams extends Equatable {
  final String id;

  const DeleteLookingForParams({required this.id});

  @override
  List<Object> get props => [id];
}
