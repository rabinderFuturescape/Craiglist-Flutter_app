import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

// Renamed to Listing to better represent the new paradigm of classifieds
class Listing extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls; // Multiple images support
  final DateTime datePosted;
  final String sellerId;
  final String sellerName;
  final String sellerContact;
  final String location; // Housing complex or geo-location
  final bool isAvailable;
  final String condition; // New, Like New, Good, Fair, etc.
  final List<String> categories;
  final Map<String, String> specifications;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.datePosted,
    required this.sellerId,
    required this.sellerName,
    required this.sellerContact,
    required this.location,
    required this.isAvailable,
    required this.condition,
    required this.categories,
    required this.specifications,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        imageUrls,
        datePosted,
        sellerId,
        sellerName,
        sellerContact,
        location,
        isAvailable,
        condition,
        categories,
        specifications,
      ];

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      datePosted: json['datePosted'] != null
          ? DateTime.parse(json['datePosted'] as String)
          : DateTime.now(),
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      sellerContact: json['sellerContact'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      condition: json['condition'] as String? ?? 'Used',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      specifications: (json['specifications'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'datePosted': datePosted.toIso8601String(),
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerContact': sellerContact,
      'location': location,
      'isAvailable': isAvailable,
      'condition': condition,
      'categories': categories,
      'specifications': specifications,
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    DateTime? datePosted,
    String? sellerId,
    String? sellerName,
    String? sellerContact,
    String? location,
    bool? isAvailable,
    String? condition,
    List<String>? categories,
    Map<String, String>? specifications,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      datePosted: datePosted ?? this.datePosted,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerContact: sellerContact ?? this.sellerContact,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      condition: condition ?? this.condition,
      categories: categories ?? this.categories,
      specifications: specifications ?? this.specifications,
    );
  }
}

// Keep the original Product class for backward compatibility
// This will help avoid breaking changes in other parts of the code
class Product extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final DateTime datePosted;
  final DateTime? expiryDate; // New field
  final String sellerId;
  final String sellerName;
  final String sellerContact;
  final String location;
  final LatLng? coordinates; // Added coordinates field
  final bool isAvailable;
  final String condition;
  final List<String> categories;
  final Map<String, dynamic> specifications;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.datePosted,
    this.expiryDate, // New optional field
    required this.sellerId,
    required this.sellerName,
    required this.sellerContact,
    required this.location,
    this.coordinates, // Optional coordinates
    required this.isAvailable,
    required this.condition,
    required this.categories,
    required this.specifications,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Getters for backward compatibility
  String get name => title;
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls[0] : '';
  bool get isInStock => isAvailable;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      datePosted: DateTime.parse(json['datePosted'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sellerContact: json['sellerContact'] as String,
      location: json['location'] as String,
      coordinates: json['coordinates'] != null
          ? LatLng(
              json['coordinates']['latitude'], json['coordinates']['longitude'])
          : null,
      isAvailable: json['isAvailable'] as bool,
      condition: json['condition'] as String,
      categories: List<String>.from(json['categories'] as List),
      specifications: Map<String, dynamic>.from(json['specifications'] as Map),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'datePosted': datePosted.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerContact': sellerContact,
      'location': location,
      'coordinates': coordinates != null
          ? {
              'latitude': coordinates!.latitude,
              'longitude': coordinates!.longitude
            }
          : null,
      'isAvailable': isAvailable,
      'condition': condition,
      'categories': categories,
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    DateTime? datePosted,
    DateTime? expiryDate,
    String? sellerId,
    String? sellerName,
    String? sellerContact,
    String? location,
    LatLng? coordinates,
    bool? isAvailable,
    String? condition,
    List<String>? categories,
    Map<String, dynamic>? specifications,
    double? rating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      datePosted: datePosted ?? this.datePosted,
      expiryDate: expiryDate ?? this.expiryDate,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerContact: sellerContact ?? this.sellerContact,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      isAvailable: isAvailable ?? this.isAvailable,
      condition: condition ?? this.condition,
      categories: categories ?? this.categories,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        imageUrls,
        datePosted,
        expiryDate,
        sellerId,
        sellerName,
        sellerContact,
        location,
        coordinates,
        isAvailable,
        condition,
        categories,
        specifications,
        rating,
        reviewCount,
      ];
}
