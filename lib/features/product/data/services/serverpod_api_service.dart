import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';

class ServerpodApiService {
  static const String baseUrl = 'https://mock-serverpod-api.aws.com';
  static const String authToken = '123456'; // Mock auth token

  // Mock user data
  static const Map<String, dynamic> mockUser = {
    'id': 'user123',
    'name': 'John Doe',
    'email': 'john@example.com',
  };

  // Mock image upload
  Future<List<String>> uploadImages(List<File> images) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock URLs
    return List.generate(
      images.length,
      (index) =>
          'https://mock-cdn.aws.com/images/${DateTime.now().millisecondsSinceEpoch}_$index.jpg',
    );
  }

  // Mock create listing
  Future<Listing> createListing(Listing listing) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return the listing with a mock ID
    return listing.copyWith(
      id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // Mock get user data
  Future<Map<String, dynamic>> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return mockUser;
  }

  // Mock authentication
  Future<Map<String, dynamic>> authenticate(
      String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (password == '123456') {
      return {
        'token': authToken,
        'user': mockUser,
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
