import 'package:equatable/equatable.dart';
import '../../domain/entities/looking_for_item.dart';

/// Events for the LookingForBloc
abstract class LookingForEvent extends Equatable {
  const LookingForEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all "Looking For" items
class LoadLookingForItems extends LookingForEvent {
  const LoadLookingForItems();
}

/// Event to load "Looking For" items for a specific user
class LoadUserLookingForItems extends LookingForEvent {
  final String userId;

  const LoadUserLookingForItems(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new "Looking For" item
class CreateLookingForItemEvent extends LookingForEvent {
  final LookingForItem item;

  const CreateLookingForItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

/// Event to update an existing "Looking For" item
class UpdateLookingForItemEvent extends LookingForEvent {
  final LookingForItem item;

  const UpdateLookingForItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

/// Event to delete a "Looking For" item
class DeleteLookingForItemEvent extends LookingForEvent {
  final String id;

  const DeleteLookingForItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to check and update expired items
class CheckExpiredItemsEvent extends LookingForEvent {
  const CheckExpiredItemsEvent();
}
