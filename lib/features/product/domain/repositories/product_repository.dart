import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

/// Repository interface for product-related operations
abstract class ProductRepository {
  /// Get a list of products with optional filtering
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  });

  /// Get a single product by ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Create a new product
  Future<Either<Failure, Product>> createProduct(Product product);

  /// Update an existing product
  Future<Either<Failure, Product>> updateProduct(String id, Product product);

  /// Delete a product
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Search products by query
  Future<Either<Failure, List<Product>>> searchProducts(String query);
}
