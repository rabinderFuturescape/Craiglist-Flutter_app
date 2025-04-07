import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/counter.dart';

abstract class CounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Counter>> incrementCounter(Counter counter);
  Future<Either<Failure, Counter>> decrementCounter(Counter counter);
} 