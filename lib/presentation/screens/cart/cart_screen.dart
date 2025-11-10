import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onContinueShopping});

  final VoidCallback? onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyles.h5.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Continue Shopping',
                    onPressed:
                        onContinueShopping ?? () => context.go('/'),
                    type: ButtonType.primary,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: Responsive.getScreenPadding(context),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildCartItem(context, item);
                  },
                ),
              ),
              _buildCartSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surface,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surface,
                  child: const Icon(Icons.error_outline),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.brand,
                    style: TextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${item.product.price.toStringAsFixed(2)}',
                    style: TextStyles.priceSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<CartBloc>().add(RemoveFromCart(item.id));
                  },
                  color: AppColors.error,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (item.quantity > 1) {
                          context.read<CartBloc>().add(
                                UpdateCartItemQuantity(
                                  itemId: item.id,
                                  quantity: item.quantity - 1,
                                ),
                              );
                        }
                      },
                    ),
                    Text(
                      item.quantity.toString(),
                      style: TextStyles.bodyLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        context.read<CartBloc>().add(
                              UpdateCartItemQuantity(
                                itemId: item.id,
                                quantity: item.quantity + 1,
                              ),
                            );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyles.priceSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartState state) {
    return Container(
      padding: Responsive.getScreenPadding(context),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyles.bodyLarge,
              ),
              Text(
                'Rs ${state.totalPrice.toStringAsFixed(2)}',
                style: TextStyles.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: TextStyles.bodyMedium,
              ),
              Text(
                'Rs 5.00',
                style: TextStyles.bodyMedium,
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyles.h5,
              ),
              Text(
                'Rs ${(state.totalPrice + 5.00).toStringAsFixed(2)}',
                style: TextStyles.price,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Proceed to Checkout',
            onPressed: () => context.go('/checkout'),
            isFullWidth: true,
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}

