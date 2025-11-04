part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoaded extends CartState {
  const CartLoaded({required List<CartItemModel> items}) : super(items: items);
}

