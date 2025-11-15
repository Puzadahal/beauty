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
    on<ToggleItemSelection>(_onToggleItemSelection);
    on<SelectAllItems>(_onSelectAllItems);
    on<DeselectAllItems>(_onDeselectAllItems);
    on<BuyNowItem>(_onBuyNowItem);
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
        // Preserve the existing selection state when updating quantity
        isSelected: currentItems[existingIndex].isSelected,
      );
    } else {
      // New items are not selected by default
      currentItems.add(event.item.copyWith(
        id: const Uuid().v4(),
        isSelected: false,
      ));
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

  void _onToggleItemSelection(
    ToggleItemSelection event,
    Emitter<CartState> emit,
  ) {
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((item) => item.id == event.itemId);
    
    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(
        isSelected: !currentItems[index].isSelected,
      );
    }

    emit(CartLoaded(items: currentItems));
  }

  void _onSelectAllItems(
    SelectAllItems event,
    Emitter<CartState> emit,
  ) {
    final currentItems = state.items.map((item) => item.copyWith(isSelected: true)).toList();
    emit(CartLoaded(items: currentItems));
  }

  void _onDeselectAllItems(
    DeselectAllItems event,
    Emitter<CartState> emit,
  ) {
    final currentItems = state.items.map((item) => item.copyWith(isSelected: false)).toList();
    emit(CartLoaded(items: currentItems));
  }

  void _onBuyNowItem(
    BuyNowItem event,
    Emitter<CartState> emit,
  ) {
    // Deselect all items first, then select only the clicked item
    final currentItems = state.items.map((item) {
      return item.copyWith(isSelected: item.id == event.itemId);
    }).toList();
    emit(CartLoaded(items: currentItems));
  }
}

