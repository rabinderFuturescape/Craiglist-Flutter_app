import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_data_source.dart';

class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final counter = await localDataSource.getCounter();
      return Right(counter);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Counter>> incrementCounter(Counter counter) async {
    try {
      final updatedCounter = await localDataSource.incrementCounter(counter);
      return Right(updatedCounter);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Counter>> decrementCounter(Counter counter) async {
    try {
      final updatedCounter = await localDataSource.decrementCounter(counter);
      return Right(updatedCounter);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
