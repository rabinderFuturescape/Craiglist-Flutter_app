import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userId =
          await localDataSource.signIn(email: email, password: password);
      return Right(userId);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, String>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userId = await localDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );
      return Right(userId);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
