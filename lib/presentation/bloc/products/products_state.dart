part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState({this.categories = const []});

  final List<String> categories;

  @override
  List<Object?> get props => [categories];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial({super.categories = const []});
}

class ProductsLoading extends ProductsState {
  const ProductsLoading({super.categories = const []});
}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;

  const ProductsLoaded({required this.products, super.categories = const []});

  @override
  List<Object?> get props => [products, categories];
}

class ProductLoaded extends ProductsState {
  final ProductModel product;

  const ProductLoaded({required this.product, super.categories = const []});

  @override
  List<Object?> get props => [product, categories];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError({required this.message, super.categories = const []});

  @override
  List<Object?> get props => [message, categories];
}
