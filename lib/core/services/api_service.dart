import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/product/domain/entities/product.dart';
import '../error/failures.dart';
import 'secure_storage_service.dart';
import 'token_manager.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final SecureStorageService _secureStorage;
  final TokenManager _tokenManager;

  ApiService({
    this.baseUrl =
        'https://api.example.com', // Replace with your actual API URL
    http.Client? client,
    SecureStorageService? secureStorage,
    TokenManager? tokenManager,
  }) :
    _client = client ?? http.Client(),
    _secureStorage = secureStorage ?? SecureStorageService(),
    _tokenManager = tokenManager ?? TokenManager(secureStorage: secureStorage);

  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (filters != null) ...filters,
      };

      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/products').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        _handleApiError(response);
        // The line below will never be reached if _handleApiError throws an exception
        return [];
      }
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to load products: $e');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ServerFailure(
          message: 'Product not found',
          code: response.statusCode,
        );
      } else {
        _handleApiError(response);
        // The line below will never be reached if _handleApiError throws an exception
        throw ServerFailure(message: 'Failed to get product');
      }
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to get product: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final queryParams = {
        'q': query,
      };

      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/products/search').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        _handleApiError(response);
        // The line below will never be reached if _handleApiError throws an exception
        return [];
      }
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to search products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      } else {
        _handleApiError(response);
        // The line below will never be reached if _handleApiError throws an exception
        throw ServerFailure(message: 'Failed to create product');
      }
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to create product: $e');
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ServerFailure(
          message: 'Product not found',
          code: response.statusCode,
        );
      } else {
        _handleApiError(response);
        // The line below will never be reached if _handleApiError throws an exception
        throw ServerFailure(message: 'Failed to update product');
      }
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw ServerFailure(
          message: 'Product not found',
          code: response.statusCode,
        );
      } else {
        _handleApiError(response);
        // The line below will never be reached if _handleApiError throws an exception
      }
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to delete product: $e');
    }
  }

  void dispose() {
    _client.close();
  }

  /// Get headers for API requests with authentication token if available
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      // Get token from token manager (handles expiration and refresh)
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('Error getting token for API request: $e');
    }

    return headers;
  }

  /// Handle API response errors consistently
  void _handleApiError(http.Response response) {
    String errorMessage = 'Unknown error';

    try {
      // Try to parse error message from response body
      final errorBody = json.decode(response.body);
      errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Server error';
    } catch (e) {
      // If parsing fails, use a generic message
      errorMessage = 'Server error: ${response.statusCode}';
    }

    if (response.statusCode == 401) {
      throw AuthFailure(message: errorMessage);
    } else if (response.statusCode == 403) {
      throw AuthFailure(message: 'Access denied: $errorMessage');
    } else if (response.statusCode == 404) {
      throw ServerFailure(
        message: 'Resource not found: $errorMessage',
        code: response.statusCode,
      );
    } else if (response.statusCode >= 500) {
      throw ServerFailure(
        message: 'Server error: $errorMessage',
        code: response.statusCode,
      );
    } else {
      throw ServerFailure(
        message: errorMessage,
        code: response.statusCode,
      );
    }
  }

  /// Attempt to refresh the token and retry a failed request
  Future<http.Response> _retryWithRefreshedToken(
    Future<http.Response> Function() requestFunction
  ) async {
    // Try to refresh the token
    final refreshedToken = await _tokenManager.refreshToken();
    if (refreshedToken == null) {
      // If refresh fails, throw auth failure
      throw const AuthFailure(message: 'Token refresh failed');
    }

    // Retry the original request with the new token
    return await requestFunction();
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw ServerException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
