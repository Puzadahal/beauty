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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to the previous screen
            if (context.canPop()) {
              context.pop();
            } else {
              // If there's no previous route, go to home
              context.go('/');
            }
          },
        ),
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
              _buildSelectionHeader(context, state),
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
            Checkbox(
              value: item.isSelected,
              onChanged: (value) {
                context.read<CartBloc>().add(ToggleItemSelection(item.id));
              },
            ),
            const SizedBox(width: 8),
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
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Buy Now - select only this item and go to checkout
                      // First, deselect all items and select only this one
                      context.read<CartBloc>().add(BuyNowItem(item.id));
                      // Use a small delay to ensure state is updated
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (context.mounted) {
                          context.go('/checkout');
                        }
                      });
                    },
                    icon: const Icon(Icons.shopping_bag, size: 16),
                    label: const Text('Buy Now'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
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

  Widget _buildSelectionHeader(BuildContext context, CartState state) {
    final allSelected = state.items.isNotEmpty && 
        state.items.every((item) => item.isSelected);
    final someSelected = state.items.any((item) => item.isSelected);

    return Container(
      padding: Responsive.getScreenPadding(context),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            tristate: true,
            onChanged: (value) {
              if (allSelected) {
                context.read<CartBloc>().add(const DeselectAllItems());
              } else {
                context.read<CartBloc>().add(const SelectAllItems());
              }
            },
          ),
          const SizedBox(width: 8),
          Text(
            allSelected 
                ? 'Deselect All' 
                : someSelected 
                    ? 'Select All' 
                    : 'Select Items',
            style: TextStyles.bodyMedium,
          ),
          const Spacer(),
          if (someSelected)
            Text(
              '${state.selectedItemsCount} item${state.selectedItemsCount != 1 ? 's' : ''} selected',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartState state) {
    final selectedItems = state.selectedItems;
    final hasSelectedItems = selectedItems.isNotEmpty;

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
                'Rs ${state.selectedTotalPrice.toStringAsFixed(2)}',
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
                'Rs ${(state.selectedTotalPrice + 5.00).toStringAsFixed(2)}',
                style: TextStyles.price,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: hasSelectedItems 
                ? 'Proceed to Checkout (${state.selectedItemsCount} item${state.selectedItemsCount != 1 ? 's' : ''})'
                : 'Select Items to Checkout',
            onPressed: hasSelectedItems 
                ? () => context.go('/checkout')
                : null,
            isFullWidth: true,
            type: ButtonType.primary,
          ),
          if (!hasSelectedItems)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select at least one item to proceed',
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

