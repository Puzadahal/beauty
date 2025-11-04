import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/cart_item_model.dart';
import 'package:uuid/uuid.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    emit(CartLoaded(items: state.items));
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final currentItems = List<CartItemModel>.from(state.items);
    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == event.item.product.id &&
          item.selectedSize == event.item.selectedSize &&
          item.selectedColor == event.item.selectedColor,
    );

    if (existingIndex >= 0) {
      currentItems[existingIndex] = currentItems[existingIndex].copyWith(
        quantity: currentItems[existingIndex].quantity + event.item.quantity,
      );
    } else {
      currentItems.add(event.item.copyWith(id: const Uuid().v4()));
    }

    emit(CartLoaded(items: currentItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentItems = List<CartItemModel>.from(state.items);
    currentItems.removeWhere((item) => item.id == event.itemId);
    emit(CartLoaded(items: currentItems));
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) {
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((item) => item.id == event.itemId);
    
    if (index >= 0) {
      if (event.quantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index] = currentItems[index].copyWith(
          quantity: event.quantity,
        );
      }
    }

    emit(CartLoaded(items: currentItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartLoaded(items: []));
  }
}

