import 'package:equatable/equatable.dart';
import '../../domain/entities/looking_for_item.dart';

/// States for the LookingForBloc
abstract class LookingForState extends Equatable {
  const LookingForState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LookingForInitial extends LookingForState {
  const LookingForInitial();
}

/// Loading state
class LookingForLoading extends LookingForState {
  const LookingForLoading();
}

/// State when items are loaded successfully
class LookingForLoaded extends LookingForState {
  final List<LookingForItem> items;

  const LookingForLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// State when a single item is loaded successfully
class LookingForItemLoaded extends LookingForState {
  final LookingForItem item;

  const LookingForItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

/// State when an item is created successfully
class LookingForItemCreated extends LookingForState {
  final LookingForItem item;

  const LookingForItemCreated(this.item);

  @override
  List<Object?> get props => [item];
}

/// State when an item is updated successfully
class LookingForItemUpdated extends LookingForState {
  final LookingForItem item;

  const LookingForItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

/// State when an item is deleted successfully
class LookingForItemDeleted extends LookingForState {
  final String id;

  const LookingForItemDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// State when expired items are checked and updated
class ExpiredItemsChecked extends LookingForState {
  final int expiredCount;

  const ExpiredItemsChecked(this.expiredCount);

  @override
  List<Object?> get props => [expiredCount];
}

/// Error state
class LookingForError extends LookingForState {
  final String message;

  const LookingForError(this.message);

  @override
  List<Object?> get props => [message];
}
