import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../data/models/product_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/responsive.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getResponsiveValue(
                    context,
                    mobile: 10,
                    tablet: 12,
                    desktop: 14,
                  ),
                  vertical: Responsive.getResponsiveValue(
                    context,
                    mobile: 10,
                    tablet: 12,
                    desktop: 14,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 140;
                    final spacing = isCompact ? 4.0 : 6.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCategory(context),
                            SizedBox(height: spacing / 2),
                            _buildTitle(context, compact: isCompact),
                            SizedBox(height: spacing / 2),
                            _buildBrand(context),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRating(context, compact: isCompact),
                            SizedBox(height: spacing),
                            _buildPrice(context, compact: isCompact),
                            if (onAddToCart != null) ...[
                              SizedBox(height: spacing),
                              _buildAddToCartButton(
                                context,
                                compact: isCompact,
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: Responsive.getResponsiveValue(
            context,
            mobile: 0.7,
            tablet: 0.75,
            desktop: 0.8,
          ),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.error_outline),
            ),
          ),
        ),
        if (product.isOnSale)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
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
          ),
        if (product.isFeatured)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildCategory(BuildContext context) {
    return Text(
      product.category.toUpperCase(),
      style: TextStyles.overline.copyWith(color: AppColors.textSecondary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTitle(BuildContext context, {required bool compact}) {
    final int maxLines = compact
        ? 1
        : Responsive.getResponsiveValue(
            context,
            mobile: 1.0,
            tablet: 2.0,
            desktop: 2.0,
          ).round();
    return Text(
      product.name,
      style: TextStyles.labelLarge,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBrand(BuildContext context) {
    return Text(
      product.brand,
      style: TextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating(BuildContext context, {required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: RatingBarIndicator(
            rating: product.rating,
            itemBuilder: (context, index) =>
                const Icon(Icons.star, color: Colors.amber),
            itemSize: compact
                ? 12
                : Responsive.getResponsiveValue(
                    context,
                    mobile: 13,
                    tablet: 14,
                    desktop: 16,
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '(${product.reviewCount})',
            style: TextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(BuildContext context, {required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'Rs ${product.price.toStringAsFixed(2)}',
            style: compact
                ? TextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)
                : TextStyles.priceSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (product.originalPrice != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Rs ${product.originalPrice!.toStringAsFixed(2)}',
              style: compact
                  ? TextStyles.bodySmall.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary,
                    )
                  : TextStyles.priceOriginal,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context, {required bool compact}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
          textStyle: TextStyles.buttonSmall,
        ),
        child: const Text('Add to Cart'),
      ),
    );
  }
}
