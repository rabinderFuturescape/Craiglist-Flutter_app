import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_expired_items.dart';
import '../../domain/usecases/create_looking_for_item.dart';
import '../../domain/usecases/delete_looking_for_item.dart';
import '../../domain/usecases/get_looking_for_items.dart';
import '../../domain/usecases/get_user_looking_for_items.dart';
import '../../domain/usecases/update_looking_for_item.dart';
import 'looking_for_event.dart';
import 'looking_for_state.dart';

/// BLoC for the "Looking For" feature
class LookingForBloc extends Bloc<LookingForEvent, LookingForState> {
  final GetLookingForItems getLookingForItems;
  final GetUserLookingForItems getUserLookingForItems;
  final CreateLookingForItem createLookingForItem;
  final UpdateLookingForItem updateLookingForItem;
  final DeleteLookingForItem deleteLookingForItem;
  final CheckExpiredItems checkExpiredItems;

  LookingForBloc({
    required this.getLookingForItems,
    required this.getUserLookingForItems,
    required this.createLookingForItem,
    required this.updateLookingForItem,
    required this.deleteLookingForItem,
    required this.checkExpiredItems,
  }) : super(const LookingForInitial()) {
    on<LoadLookingForItems>(_onLoadLookingForItems);
    on<LoadUserLookingForItems>(_onLoadUserLookingForItems);
    on<CreateLookingForItemEvent>(_onCreateLookingForItem);
    on<UpdateLookingForItemEvent>(_onUpdateLookingForItem);
    on<DeleteLookingForItemEvent>(_onDeleteLookingForItem);
    on<CheckExpiredItemsEvent>(_onCheckExpiredItems);
  }

  /// Handle the LoadLookingForItems event
  Future<void> _onLoadLookingForItems(
    LoadLookingForItems event,
    Emitter<LookingForState> emit,
  ) async {
    emit(const LookingForLoading());
    final result = await getLookingForItems(NoParams());
    result.fold(
      (failure) => emit(LookingForError(failure.toString())),
      (items) => emit(LookingForLoaded(items)),
    );
  }

  /// Handle the LoadUserLookingForItems event
  Future<void> _onLoadUserLookingForItems(
    LoadUserLookingForItems event,
    Emitter<LookingForState> emit,
  ) async {
    emit(const LookingForLoading());
    final result = await getUserLookingForItems(UserParams(userId: event.userId));
    result.fold(
      (failure) => emit(LookingForError(failure.toString())),
      (items) => emit(LookingForLoaded(items)),
    );
  }

  /// Handle the CreateLookingForItemEvent event
  Future<void> _onCreateLookingForItem(
    CreateLookingForItemEvent event,
    Emitter<LookingForState> emit,
  ) async {
    emit(const LookingForLoading());
    final result = await createLookingForItem(CreateLookingForParams(item: event.item));
    result.fold(
      (failure) => emit(LookingForError(failure.toString())),
      (item) => emit(LookingForItemCreated(item)),
    );
  }

  /// Handle the UpdateLookingForItemEvent event
  Future<void> _onUpdateLookingForItem(
    UpdateLookingForItemEvent event,
    Emitter<LookingForState> emit,
  ) async {
    emit(const LookingForLoading());
    final result = await updateLookingForItem(UpdateLookingForParams(item: event.item));
    result.fold(
      (failure) => emit(LookingForError(failure.toString())),
      (item) => emit(LookingForItemUpdated(item)),
    );
  }

  /// Handle the DeleteLookingForItemEvent event
  Future<void> _onDeleteLookingForItem(
    DeleteLookingForItemEvent event,
    Emitter<LookingForState> emit,
  ) async {
    emit(const LookingForLoading());
    final result = await deleteLookingForItem(DeleteLookingForParams(id: event.id));
    result.fold(
      (failure) => emit(LookingForError(failure.toString())),
      (success) => emit(LookingForItemDeleted(event.id)),
    );
  }

  /// Handle the CheckExpiredItemsEvent event
  Future<void> _onCheckExpiredItems(
    CheckExpiredItemsEvent event,
    Emitter<LookingForState> emit,
  ) async {
    emit(const LookingForLoading());
    final result = await checkExpiredItems(NoParams());
    result.fold(
      (failure) => emit(LookingForError(failure.toString())),
      (expiredCount) => emit(ExpiredItemsChecked(expiredCount)),
    );
  }
}
