part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final String? category;
  final bool? featured;

  const LoadProducts({this.category, this.featured});

  @override
  List<Object?> get props => [category, featured];
}

class LoadProductById extends ProductsEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCategories extends ProductsEvent {
  const LoadCategories();
}

class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProductsByCategory extends ProductsEvent {
  final String category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

