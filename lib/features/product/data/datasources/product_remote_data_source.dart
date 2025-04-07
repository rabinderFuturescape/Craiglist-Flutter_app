import '../../domain/entities/product.dart';
import '../../../../core/services/api_service.dart';

abstract class ProductRemoteDataSource {
  /// Get a list of products with optional filtering
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  });

  /// Get a single product by ID
  Future<Product> getProductById(String id);

  /// Create a new product
  Future<Product> createProduct(Product product);

  /// Update an existing product
  Future<Product> updateProduct(String id, Product product);

  /// Delete a product
  Future<void> deleteProduct(String id);

  /// Search products by query
  Future<List<Product>> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiService _apiService;

  ProductRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    return await _apiService.getProducts(
      page: page,
      pageSize: pageSize,
      filters: filters,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    return await _apiService.getProductById(id);
  }

  @override
  Future<Product> createProduct(Product product) async {
    return await _apiService.createProduct(product);
  }

  @override
  Future<Product> updateProduct(String id, Product product) async {
    return await _apiService.updateProduct(id, product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiService.deleteProduct(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return await _apiService.searchProducts(query);
  }
}
