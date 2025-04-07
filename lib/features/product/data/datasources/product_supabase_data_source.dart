import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/supabase_client.dart';
import 'product_remote_data_source.dart';

/// Implementation of ProductRemoteDataSource using Supabase
class ProductSupabaseDataSource implements ProductRemoteDataSource {
  final AppSupabaseClient _supabaseClient;

  ProductSupabaseDataSource({
    required AppSupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Start with the base query
      var query = _supabaseClient.db('products')
          .select()
          .order('created_at', ascending: false)
          .range((page - 1) * pageSize, page * pageSize - 1);

      // Apply filters if provided
      if (filters != null) {
        if (filters.containsKey('category')) {
          query = query.contains('categories', [filters['category']]);
        }
        if (filters.containsKey('minPrice')) {
          query = query.gte('price', filters['minPrice']);
        }
        if (filters.containsKey('maxPrice')) {
          query = query.lte('price', filters['maxPrice']);
        }
        if (filters.containsKey('location')) {
          query = query.ilike('location', '%${filters['location']}%');
        }
        if (filters.containsKey('sellerId')) {
          query = query.eq('seller_id', filters['sellerId']);
        }
        if (filters.containsKey('isAvailable')) {
          query = query.eq('is_available', filters['isAvailable']);
        }
      }

      final response = await query;
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await _supabaseClient.db('products')
          .select()
          .eq('id', id)
          .single();
      
      if (response.error != null) {
        if (response.error!.message.contains('no rows found')) {
          throw NotFoundException(message: 'Product not found');
        }
        throw ServerException(message: response.error!.message);
      }

      return Product.fromJson(response.data);
    } on PostgrestException catch (e) {
      if (e.message.contains('no rows found')) {
        throw NotFoundException(message: 'Product not found');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      // Check if user is authenticated
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      // Convert product to JSON and add user ID
      final productJson = product.toJson();
      productJson['seller_id'] = user.id;

      final response = await _supabaseClient.db('products')
          .insert(productJson)
          .select()
          .single();
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return Product.fromJson(response.data);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Product> updateProduct(String id, Product product) async {
    try {
      // Check if user is authenticated
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      // Convert product to JSON and remove id (can't update primary key)
      final productJson = product.toJson();
      productJson.remove('id');

      final response = await _supabaseClient.db('products')
          .update(productJson)
          .eq('id', id)
          .eq('seller_id', user.id) // Ensure user owns the product
          .select()
          .single();
      
      if (response.error != null) {
        if (response.error!.message.contains('no rows found')) {
          throw NotFoundException(message: 'Product not found or not owned by user');
        }
        throw ServerException(message: response.error!.message);
      }

      return Product.fromJson(response.data);
    } on PostgrestException catch (e) {
      if (e.message.contains('no rows found')) {
        throw NotFoundException(message: 'Product not found or not owned by user');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      // Check if user is authenticated
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final response = await _supabaseClient.db('products')
          .delete()
          .eq('id', id)
          .eq('seller_id', user.id); // Ensure user owns the product
      
      if (response.error != null) {
        if (response.error!.message.contains('no rows found')) {
          throw NotFoundException(message: 'Product not found or not owned by user');
        }
        throw ServerException(message: response.error!.message);
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _supabaseClient.db('products')
          .select()
          .or('title.ilike.%${query}%,description.ilike.%${query}%')
          .eq('is_available', true)
          .order('created_at', ascending: false);
      
      if (response.error != null) {
        throw ServerException(message: response.error!.message);
      }

      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Upload product images to Supabase Storage
  Future<List<String>> uploadProductImages(List<String> imagePaths, String productId) async {
    try {
      final user = _supabaseClient.currentUser;
      if (user == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final List<String> imageUrls = [];
      
      for (final imagePath in imagePaths) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
        final filePath = 'products/$productId/$fileName';
        
        final response = await _supabaseClient.storage
            .from('product_images')
            .upload(filePath, imagePath);
        
        if (response.error != null) {
          throw ServerException(message: response.error!.message);
        }
        
        // Get public URL
        final publicUrl = _supabaseClient.storage
            .from('product_images')
            .getPublicUrl(filePath);
        
        imageUrls.add(publicUrl);
      }
      
      return imageUrls;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
