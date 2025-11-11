import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ApiService apiService;

  ProductsBloc({required this.apiService}) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductById>(_onLoadProductById);
    on<LoadCategories>(_onLoadCategories);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    final categories = state.categories;
    emit(ProductsLoading(categories: categories));
    try {
      final products = await apiService.getProducts(
        category: event.category,
        featured: event.featured,
      );
      emit(ProductsLoaded(products: products, categories: categories));
    } catch (e) {
      emit(ProductsError(message: e.toString(), categories: categories));
    }
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductsState> emit,
  ) async {
    final categories = state.categories;
    emit(ProductsLoading(categories: categories));
    try {
      final product = await apiService.getProductById(event.id);
      if (product != null) {
        emit(ProductLoaded(product: product, categories: categories));
      } else {
        emit(
          ProductsError(message: 'Product not found', categories: categories),
        );
      }
    } catch (e) {
      emit(ProductsError(message: e.toString(), categories: categories));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final categories = await apiService.getCategories();
      final currentState = state;
      if (currentState is ProductsLoaded) {
        emit(
          ProductsLoaded(
            products: currentState.products,
            categories: categories,
          ),
        );
      } else if (currentState is ProductLoaded) {
        emit(
          ProductLoaded(product: currentState.product, categories: categories),
        );
      } else if (currentState is ProductsLoading) {
        emit(ProductsLoading(categories: categories));
      } else if (currentState is ProductsError) {
        emit(
          ProductsError(message: currentState.message, categories: categories),
        );
      } else {
        emit(ProductsInitial(categories: categories));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString(), categories: state.categories));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    final categories = state.categories;
    emit(ProductsLoading(categories: categories));
    try {
      final products = await apiService.getProducts(search: event.query);
      emit(ProductsLoaded(products: products, categories: categories));
    } catch (e) {
      emit(ProductsError(message: e.toString(), categories: categories));
    }
  }

  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductsState> emit,
  ) async {
    final categories = state.categories;
    emit(ProductsLoading(categories: categories));
    try {
      final products = await apiService.getProducts(category: event.category);
      emit(ProductsLoaded(products: products, categories: categories));
    } catch (e) {
      emit(ProductsError(message: e.toString(), categories: categories));
    }
  }
}
