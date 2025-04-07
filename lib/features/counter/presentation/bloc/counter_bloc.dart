import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../../../core/usecases/usecase.dart';

// Events
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

class GetCounterEvent extends CounterEvent {}

class IncrementCounterEvent extends CounterEvent {}

class DecrementCounterEvent extends CounterEvent {}

// States
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object?> get props => [];
}

class CounterInitial extends CounterState {}

class CounterLoading extends CounterState {}

class CounterLoaded extends CounterState {
  final Counter counter;

  const CounterLoaded(this.counter);

  @override
  List<Object?> get props => [counter];
}

class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final GetCounter getCounter;

  CounterBloc({required this.getCounter}) : super(CounterInitial()) {
    on<GetCounterEvent>(_onGetCounter);
    on<IncrementCounterEvent>(_onIncrementCounter);
    on<DecrementCounterEvent>(_onDecrementCounter);
  }

  Future<void> _onGetCounter(
      GetCounterEvent event, Emitter<CounterState> emit) async {
    emit(CounterLoading());
    final result = await getCounter(NoParams());
    result.fold(
      (failure) => emit(const CounterError('Failed to get counter')),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  Future<void> _onIncrementCounter(
      IncrementCounterEvent event, Emitter<CounterState> emit) async {
    if (state is CounterLoaded) {
      final currentCounter = (state as CounterLoaded).counter;
      emit(CounterLoaded(Counter(currentCounter.value + 1)));
    }
  }

  Future<void> _onDecrementCounter(
      DecrementCounterEvent event, Emitter<CounterState> emit) async {
    if (state is CounterLoaded) {
      final currentCounter = (state as CounterLoaded).counter;
      emit(CounterLoaded(Counter(currentCounter.value - 1)));
    }
  }
}
