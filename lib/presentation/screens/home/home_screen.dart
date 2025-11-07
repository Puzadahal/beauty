import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../bloc/products/products_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/cart_item_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  static const List<_QuickFilter> _quickFilters = <_QuickFilter>[
    _QuickFilter(label: 'All Products', category: null),
    _QuickFilter(label: 'Skincare', category: 'Skincare'),
    _QuickFilter(label: 'Cosmetics', category: 'Cosmetics'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
    context.read<ProductsBloc>().add(const LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 8),
            _buildQuickFilters(context),
            const SizedBox(height: 8),
            _buildCategoryFilter(context),
            Expanded(
              child: _buildProductsGrid(context),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingCartButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Beauty & Cosmetics',
        style: TextStyles.h5.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated && state.user.isAdmin) {
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () => context.go('/admin'),
                tooltip: 'Admin Panel',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = _quickFilters[index];
          final isSelected = _selectedCategory == filter.category;

          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _selectedCategory = filter.category;
              });

              if (filter.category == null) {
                context.read<ProductsBloc>().add(const LoadProducts());
              } else {
                context
                    .read<ProductsBloc>()
                    .add(FilterProductsByCategory(filter.category!));
              }
            },
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: _quickFilters.length,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        Responsive.getResponsiveValue(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ProductsBloc>().add(const LoadProducts());
                  },
                )
              : null,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            context.read<ProductsBloc>().add(SearchProducts(value));
          } else {
            context.read<ProductsBloc>().add(const LoadProducts());
          }
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is! CategoriesLoaded) {
          return const SizedBox.shrink();
        }

        final quickFilterSet = _quickFilters
            .where((filter) => filter.category != null)
            .map((filter) => filter.category!.toLowerCase())
            .toSet();

        final categories = state.categories
            .where((category) {
              final lower = category.toLowerCase();
              return lower != 'all' &&
                  lower != 'all products' &&
                  !quickFilterSet.contains(lower);
            })
            .toList();

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...categories.map(
                (category) => _buildCategoryChip(context, category, category),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String? category,
    String label,
  ) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryLight,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          if (selected && category != null) {
            context
                .read<ProductsBloc>()
                .add(FilterProductsByCategory(category));
          } else {
            context.read<ProductsBloc>().add(const LoadProducts());
          }
        },
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<ProductsBloc>().add(const LoadProducts());
                  },
                ),
              ],
            ),
          );
        }

        if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            return Center(
              child: Text(
                'No products found',
                style: TextStyles.bodyLarge,
              ),
            );
          }

          final crossAxisCount = Responsive.getGridCrossAxisCount(context);

          return GridView.builder(
            padding: EdgeInsets.all(
              Responsive.getResponsiveValue(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: Responsive.getResponsiveValue(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
              mainAxisSpacing: Responsive.getResponsiveValue(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
              childAspectRatio: Responsive.getResponsiveValue(
                context,
                mobile: 0.72,
                tablet: 0.8,
                desktop: 0.86,
              ),
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  context.push('/product/${product.id}');
                },
                onAddToCart: () {
                  context.read<CartBloc>().add(
                        AddToCart(
                          CartItemModel(
                            id: '',
                            product: product,
                            quantity: 1,
                          ),
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFloatingCartButton(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state.totalItems;
        if (itemCount == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => context.go('/cart'),
          backgroundColor: AppColors.primary,
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              if (itemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      itemCount > 9 ? '9+' : itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: Text(
            'Cart (\$${state.totalPrice.toStringAsFixed(2)})',
            style: TextStyles.buttonMedium.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }
}

class _QuickFilter {
  const _QuickFilter({required this.label, this.category});

  final String label;
  final String? category;
}

