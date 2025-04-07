import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/error/failures.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProducts extends ProductEvent {
  final String? category;
  final RangeValues? priceRange;
  final String? sortOption;

  const FilterProducts({this.category, this.priceRange, this.sortOption});

  @override
  List<Object?> get props => [category, priceRange, sortOption];
}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveProduct extends ProductEvent {
  final String productId;

  const RemoveProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ToggleViewMode extends ProductEvent {
  const ToggleViewMode();
}

// States
abstract class ProductState extends Equatable {
  final bool isGridView;

  const ProductState({this.isGridView = true});

  @override
  List<Object?> get props => [isGridView];
}

class ProductInitial extends ProductState {
  const ProductInitial() : super();
}

class ProductLoading extends ProductState {
  const ProductLoading({required bool isGridView})
      : super(isGridView: isGridView);
}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products, {required bool isGridView})
      : super(isGridView: isGridView);

  @override
  List<Object?> get props => [products, isGridView];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message, {required bool isGridView})
      : super(isGridView: isGridView);

  @override
  List<Object?> get props => [message, isGridView];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  // Keep dummy products as fallback
  final List<Product> _dummyProducts = [
    Product(
      id: '1',
      title: '2 BHK Apartment for Rent',
      description: 'Spacious 2 BHK apartment with modern amenities',
      price: 25000,
      imageUrls: ['https://picsum.photos/800/600?random=1'],
      categories: ['Real Estate', 'Apartment'],
      location: 'Thane West, Mumbai',
      datePosted: DateTime.now().subtract(const Duration(hours: 2)),
      isAvailable: true,
      sellerId: 'user1',
      sellerName: 'John Doe',
      sellerContact: '+91 9876543210',
      condition: 'Excellent',
      specifications: {
        'Bedrooms': '2',
        'Bathrooms': '2',
        'Furnished': 'Yes',
        'Area': '1000 sq ft'
      },
    ),
    Product(
      id: '2',
      title: 'iPhone 13 Pro - Like New',
      description: '1 year old iPhone 13 Pro in excellent condition',
      price: 75000,
      imageUrls: ['https://picsum.photos/800/600?random=2'],
      categories: ['Electronics', 'Mobile Phones'],
      location: 'Andheri East, Mumbai',
      datePosted: DateTime.now().subtract(const Duration(days: 1)),
      isAvailable: true,
      sellerId: 'user2',
      sellerName: 'Jane Smith',
      sellerContact: '+91 9876543211',
      condition: 'Like New',
      specifications: {
        'Storage': '256 GB',
        'Color': 'Pacific Blue',
        'Warranty': '6 months remaining',
        'Accessories': 'Original charger, box'
      },
    ),
    Product(
      id: '3',
      title: 'Royal Enfield Classic 350',
      description: '2020 model Royal Enfield Classic 350 in mint condition',
      price: 120000,
      imageUrls: ['https://picsum.photos/800/600?random=3'],
      categories: ['Vehicles', 'Motorcycles'],
      location: 'Pune, Maharashtra',
      datePosted: DateTime.now().subtract(const Duration(days: 3)),
      isAvailable: false,
      sellerId: 'user3',
      sellerName: 'Mike Johnson',
      sellerContact: '+91 9876543212',
      condition: 'Used - Like New',
      specifications: {
        'Year': '2020',
        'KMs Driven': '15000',
        'Color': 'Stealth Black',
        'Insurance': 'Valid till Dec 2024'
      },
    ),
    Product(
      id: '4',
      title: 'Study Table with Chair',
      description: 'Modern study table with ergonomic chair',
      price: 8000,
      imageUrls: ['https://picsum.photos/800/600?random=4'],
      categories: ['Furniture', 'Home Office'],
      location: 'Powai, Mumbai',
      datePosted: DateTime.now().subtract(const Duration(days: 5)),
      isAvailable: true,
      sellerId: 'user4',
      sellerName: 'Sarah Wilson',
      sellerContact: '+91 9876543213',
      condition: 'Used - Good',
      specifications: {
        'Material': 'Engineered Wood',
        'Color': 'Oak Brown',
        'Dimensions': '120x60x75 cm',
        'Assembly': 'Included'
      },
    ),
    Product(
      id: '5',
      title: 'Sony PS5 with Controllers',
      description: 'PS5 with 2 controllers and 3 games',
      price: 45000,
      imageUrls: ['https://picsum.photos/800/600?random=5'],
      categories: ['Gaming', 'Electronics'],
      location: 'Bandra West, Mumbai',
      datePosted: DateTime.now().subtract(const Duration(days: 7)),
      isAvailable: true,
      sellerId: 'user5',
      sellerName: 'Alex Brown',
      sellerContact: '+91 9876543214',
      condition: 'Used - Excellent',
      specifications: {
        'Model': 'PS5 Digital Edition',
        'Storage': '825GB SSD',
        'Controllers': '2 DualSense',
        'Games': 'FIFA 23, God of War, Spider-Man'
      },
    ),
  ];

  ProductBloc({required ProductRepository productRepository}) :
    _productRepository = productRepository,
    super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProducts>(_onFilterProducts);
    on<AddProduct>(_onAddProduct);
    on<RemoveProduct>(_onRemoveProduct);
    on<ToggleViewMode>(_onToggleViewMode);
  }

  void _onToggleViewMode(ToggleViewMode event, Emitter<ProductState> emit) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(ProductLoaded(currentState.products,
          isGridView: !currentState.isGridView));
    } else if (state is ProductLoading) {
      emit(ProductLoading(isGridView: !state.isGridView));
    } else if (state is ProductError) {
      final currentState = state as ProductError;
      emit(ProductError(currentState.message,
          isGridView: !currentState.isGridView));
    }
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading(isGridView: state.isGridView));

    final result = await _productRepository.getProducts();

    result.fold(
      (failure) {
        // If repository returns a failure, use dummy data as fallback
        if (failure is NetworkFailure) {
          emit(ProductLoaded(_dummyProducts, isGridView: state.isGridView));
        } else {
          emit(ProductError(failure.message, isGridView: state.isGridView));
        }
      },
      (products) => emit(ProductLoaded(products, isGridView: state.isGridView)),
    );
  }

  void _onSearchProducts(
      SearchProducts event, Emitter<ProductState> emit) async {
    if (state is! ProductLoaded) {
      _onLoadProducts(const LoadProducts(), emit);
      return;
    }

    emit(ProductLoading(isGridView: state.isGridView));

    if (event.query.isEmpty) {
      _onLoadProducts(const LoadProducts(), emit);
      return;
    }

    final result = await _productRepository.searchProducts(event.query);

    result.fold(
      (failure) {
        // If repository returns a failure, try to search locally
        if (state is ProductLoaded) {
          final products = (state as ProductLoaded).products;
          final searchLower = event.query.toLowerCase();
          final filteredProducts = products.where((product) {
            return product.title.toLowerCase().contains(searchLower) ||
                product.description.toLowerCase().contains(searchLower) ||
                product.categories.any((cat) => cat.toLowerCase().contains(searchLower)) ||
                product.location.toLowerCase().contains(searchLower);
          }).toList();

          emit(ProductLoaded(filteredProducts, isGridView: state.isGridView));
        } else {
          emit(ProductError(failure.message, isGridView: state.isGridView));
        }
      },
      (products) => emit(ProductLoaded(products, isGridView: state.isGridView)),
    );
  }

  void _onFilterProducts(
      FilterProducts event, Emitter<ProductState> emit) async {
    if (state is! ProductLoaded) {
      _onLoadProducts(const LoadProducts(), emit);
    }

    if (state is ProductLoaded) {
      try {
        var filteredProducts = _dummyProducts;

        // Apply category filter
        if (event.category != null && event.category != 'All Categories') {
          filteredProducts = filteredProducts
              .where((product) => product.categories.contains(event.category))
              .toList();
        }

        // Apply price range filter
        if (event.priceRange != null) {
          filteredProducts = filteredProducts
              .where((product) =>
                  product.price >= event.priceRange!.start &&
                  product.price <= event.priceRange!.end)
              .toList();
        }

        // Apply sorting
        if (event.sortOption != null) {
          switch (event.sortOption) {
            case 'Newest First':
              filteredProducts
                  .sort((a, b) => b.datePosted.compareTo(a.datePosted));
              break;
            case 'Oldest First':
              filteredProducts
                  .sort((a, b) => a.datePosted.compareTo(b.datePosted));
              break;
            case 'Price: Low to High':
              filteredProducts.sort((a, b) => a.price.compareTo(b.price));
              break;
            case 'Price: High to Low':
              filteredProducts.sort((a, b) => b.price.compareTo(a.price));
              break;
          }
        }

        emit(ProductLoaded(filteredProducts, isGridView: state.isGridView));
      } catch (e) {
        emit(ProductError('Error filtering products: ${e.toString()}',
            isGridView: state.isGridView));
      }
    }
  }

  void _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    if (state is! ProductLoaded) return;

    final currentProducts = (state as ProductLoaded).products;

    // Optimistically update UI
    emit(ProductLoaded([...currentProducts, event.product], isGridView: state.isGridView));

    // Call repository
    final result = await _productRepository.createProduct(event.product);

    result.fold(
      (failure) {
        // If failed, revert to previous state and show error
        emit(ProductLoaded(currentProducts, isGridView: state.isGridView));
        emit(ProductError(failure.message, isGridView: state.isGridView));
      },
      (createdProduct) {
        // If successful, update with the created product from the server
        final updatedProducts = [...currentProducts];
        final index = updatedProducts.indexWhere((p) => p.id == event.product.id);
        if (index >= 0) {
          updatedProducts[index] = createdProduct;
        } else {
          updatedProducts.add(createdProduct);
        }
        emit(ProductLoaded(updatedProducts, isGridView: state.isGridView));
      },
    );
  }

  void _onRemoveProduct(RemoveProduct event, Emitter<ProductState> emit) async {
    if (state is! ProductLoaded) return;

    final currentProducts = (state as ProductLoaded).products;
    final productToRemove = currentProducts.firstWhere(
      (p) => p.id == event.productId,
      orElse: () => throw Exception('Product not found'),
    );

    // Optimistically update UI
    final updatedProducts = currentProducts.where((p) => p.id != event.productId).toList();
    emit(ProductLoaded(updatedProducts, isGridView: state.isGridView));

    // Call repository
    final result = await _productRepository.deleteProduct(event.productId);

    result.fold(
      (failure) {
        // If failed, revert to previous state and show error
        emit(ProductLoaded(currentProducts, isGridView: state.isGridView));
        emit(ProductError(failure.message, isGridView: state.isGridView));
      },
      (_) {
        // If successful, keep the updated state
        emit(ProductLoaded(updatedProducts, isGridView: state.isGridView));
      },
    );
  }
}
