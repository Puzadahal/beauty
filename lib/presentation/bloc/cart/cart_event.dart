part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class AddToCart extends CartEvent {
  final CartItemModel item;

  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String itemId;

  const RemoveFromCart(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class UpdateCartItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateCartItemQuantity({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class ToggleItemSelection extends CartEvent {
  final String itemId;

  const ToggleItemSelection(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class SelectAllItems extends CartEvent {
  const SelectAllItems();
}

class DeselectAllItems extends CartEvent {
  const DeselectAllItems();
}

class BuyNowItem extends CartEvent {
  final String itemId;

  const BuyNowItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

