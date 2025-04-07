import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../../product/domain/entities/product.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final Product product;
  final int quantity;

  const AddToCart({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class UpdateQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends CartEvent {}

// State
class CartState extends Equatable {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalAmount => items.fold(
        0,
        (total, item) => total + item.totalPrice,
      );

  int get itemCount => items.fold(
        0,
        (total, item) => total + item.quantity,
      );

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final existingItemIndex =
        state.items.indexWhere((item) => item.product.id == event.product.id);

    if (existingItemIndex != -1) {
      final updatedItems = List<CartItem>.from(state.items);
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + event.quantity,
      );
      emit(state.copyWith(items: updatedItems));
    } else {
      emit(state.copyWith(
        items: [
          ...state.items,
          CartItem(
            product: event.product,
            quantity: event.quantity,
          ),
        ],
      ));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    emit(state.copyWith(
      items: state.items
          .where((item) => item.product.id != event.productId)
          .toList(),
    ));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(productId: event.productId));
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == event.productId) {
        return CartItem(
          product: item.product,
          quantity: event.quantity,
        );
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
