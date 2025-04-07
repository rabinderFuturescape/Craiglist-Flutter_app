import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/looking_for_item.dart';
import '../repositories/looking_for_repository.dart';

/// Use case to create a new "Looking For" item
class CreateLookingForItem implements UseCase<LookingForItem, CreateLookingForParams> {
  final LookingForRepository repository;

  CreateLookingForItem(this.repository);

  @override
  Future<Either<Failure, LookingForItem>> call(CreateLookingForParams params) async {
    return await repository.createLookingForItem(params.item);
  }
}

class CreateLookingForParams extends Equatable {
  final LookingForItem item;

  const CreateLookingForParams({required this.item});

  @override
  List<Object> get props => [item];
}
