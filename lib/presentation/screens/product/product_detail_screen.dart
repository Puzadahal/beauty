import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/products/products_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsBloc(
        apiService: ApiService(),
      )..add(LoadProductById(productId)),
      child: Scaffold(
        body: BlocBuilder<ProductsBloc, ProductsState>(
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
                      text: 'Go Back',
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductLoaded) {
              return _buildProductDetail(context, state.product);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, product) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(context, product),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategory(context, product),
                    const SizedBox(height: 8),
                    _buildTitle(context, product),
                    const SizedBox(height: 8),
                    _buildBrand(context, product),
                    const SizedBox(height: 16),
                    _buildRating(context, product),
                    const SizedBox(height: 16),
                    _buildPrice(context, product),
                    const SizedBox(height: 16),
                    _buildDescription(context, product),
                    const SizedBox(height: 24),
                    _buildAddToCartButton(context, product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => context.go('/cart'),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(BuildContext context, product) {
    final images = [product.imageUrl, ...product.imageUrls];
    
    return SizedBox(
      height: Responsive.getResponsiveValue(
        context,
        mobile: 300,
        tablet: 400,
        desktop: 500,
      ),
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => Container(
              color: AppColors.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.error_outline),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategory(BuildContext context, product) {
    return Text(
      product.category.toUpperCase(),
      style: TextStyles.overline.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildTitle(BuildContext context, product) {
    return Text(
      product.name,
      style: TextStyles.h3,
    );
  }

  Widget _buildBrand(BuildContext context, product) {
    return Text(
      product.brand,
      style: TextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildRating(BuildContext context, product) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: product.rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '${product.rating} (${product.reviewCount} reviews)',
          style: TextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPrice(BuildContext context, product) {
    return Row(
      children: [
        Text(
          'Rs ${product.price.toStringAsFixed(2)}',
          style: TextStyles.price,
        ),
        if (product.originalPrice != null) ...[
          const SizedBox(width: 16),
          Text(
            'Rs ${product.originalPrice!.toStringAsFixed(2)}',
            style: TextStyles.priceOriginal,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context, product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyles.h5,
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context, product) {
    return CustomButton(
      text: product.isAvailable
          ? 'Add to Cart'
          : 'Out of Stock',
      onPressed: product.isAvailable
          ? () {
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
                  action: SnackBarAction(
                    label: 'View Cart',
                    onPressed: () => context.go('/cart'),
                  ),
                ),
              );
            }
          : null,
      isFullWidth: true,
      type: ButtonType.primary,
    );
  }
}

