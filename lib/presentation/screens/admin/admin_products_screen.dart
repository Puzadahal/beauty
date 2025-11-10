import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/products/products_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/product_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
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
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return _buildProductListItem(context, product);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
        ),
        title: Text(product.name),
        subtitle: Text('Rs ${product.price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditProductDialog(context, product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirmDialog(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Simplified - In production, create a full form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add product feature - Full form implementation needed'),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, ProductModel product) {
    // Simplified - In production, create a full form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${product.name} - Full form implementation needed'),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // In production, call delete API
              context.read<ProductsBloc>().add(const LoadProducts());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

