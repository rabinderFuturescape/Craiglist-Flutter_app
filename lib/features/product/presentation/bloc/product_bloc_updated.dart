import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}

class RemoveProduct extends ProductEvent {
  final String productId;

  const RemoveProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      try {
        emit(ProductLoading());

        // For testing, provide sample data
        await Future.delayed(
            const Duration(seconds: 1)); // Simulate network delay

        final List<Product> sampleProducts = [
          Product(
            id: '1',
            title: 'Slightly Used iPad Air (5th Generation)',
            description:
                'Apple M1 chip, 10.9-inch Liquid Retina display, 256GB. Only used for 3 months, selling because I upgraded.',
            price: 549.99,
            imageUrls: ['https://picsum.photos/800/600'],
            datePosted: DateTime.now().subtract(const Duration(days: 2)),
            sellerId: 'user1',
            sellerName: 'John Smith',
            sellerContact: 'john.smith@example.com',
            location: 'Sunset Apartments, Building C',
            isAvailable: true,
            condition: 'Like New',
            categories: ['Electronics', 'Tablets'],
            specifications: {
              'Display': '10.9-inch Liquid Retina',
              'Chip': 'M1',
              'Storage': '256GB',
              'Color': 'Space Gray'
            },
          ),
          Product(
            id: '2',
            title: 'Dining Table with 4 chairs',
            description:
                'Solid wood dining table with 4 matching chairs. Perfect for an apartment. Minor scratches on the table legs.',
            price: 199.99,
            imageUrls: ['https://picsum.photos/800/600?random=1'],
            datePosted: DateTime.now().subtract(const Duration(days: 5)),
            sellerId: 'user2',
            sellerName: 'Emily Johnson',
            sellerContact: '555-123-4567',
            location: 'Meadow View Complex',
            isAvailable: true,
            condition: 'Good',
            categories: ['Furniture', 'Home Goods'],
            specifications: {
              'Material': 'Wood',
              'Color': 'Brown',
              'Dimensions': '60" x 36" x 30"',
              'Chair Count': '4'
            },
          ),
          Product(
            id: '3',
            title: 'Mountain Bike - Trek Marlin 5',
            description:
                'Great condition mountain bike, only ridden a few times on trails. Includes helmet and bike lock.',
            price: 425.00,
            imageUrls: ['https://picsum.photos/800/600?random=2'],
            datePosted: DateTime.now().subtract(const Duration(days: 3)),
            sellerId: 'user3',
            sellerName: 'Mike Davidson',
            sellerContact: 'mike.d@example.com',
            location: 'Green Valley Estates',
            isAvailable: true,
            condition: 'Very Good',
            categories: ['Sports Equipment', 'Outdoor'],
            specifications: {
              'Brand': 'Trek',
              'Model': 'Marlin 5',
              'Size': 'Medium (29-inch wheels)',
              'Color': 'Black/Red'
            },
          ),
        ];

        emit(ProductLoaded(sampleProducts));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<AddProduct>((event, emit) async {
      try {
        if (state is ProductLoaded) {
          final currentProducts = (state as ProductLoaded).products;
          emit(ProductLoaded([...currentProducts, event.product]));
        }
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<RemoveProduct>((event, emit) async {
      try {
        if (state is ProductLoaded) {
          final currentProducts = (state as ProductLoaded).products;
          final updatedProducts = currentProducts
              .where((product) => product.id != event.productId)
              .toList();
          emit(ProductLoaded(updatedProducts));
        }
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}
