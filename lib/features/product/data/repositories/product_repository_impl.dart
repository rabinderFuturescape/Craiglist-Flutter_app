import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Implementation of ProductRepository that handles network connectivity and error handling
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final products = await _remoteDataSource.getProducts(
          page: page,
          pageSize: pageSize,
          filters: filters,
        );
        return Right(products);
      } on AuthFailure catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final product = await _remoteDataSource.getProductById(id);
        return Right(product);
      } on AuthFailure catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    if (await _networkInfo.isConnected) {
      try {
        final createdProduct = await _remoteDataSource.createProduct(product);
        return Right(createdProduct);
      } on AuthFailure catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(String id, Product product) async {
    if (await _networkInfo.isConnected) {
      try {
        final updatedProduct = await _remoteDataSource.updateProduct(id, product);
        return Right(updatedProduct);
      } on AuthFailure catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteProduct(id);
        return const Right(null);
      } on AuthFailure catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    if (await _networkInfo.isConnected) {
      try {
        final products = await _remoteDataSource.searchProducts(query);
        return Right(products);
      } on AuthFailure catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
