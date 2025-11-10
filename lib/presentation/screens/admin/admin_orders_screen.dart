import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../bloc/orders/orders_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../data/models/order_model.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          context.read<OrdersBloc>().add(LoadOrders(authState.user.id));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Orders'),
          ),
          body: BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              if (state is OrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is OrdersError) {
                return Center(
                  child: Text(state.message),
                );
              }

              if (state is OrdersLoaded) {
                if (state.orders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders yet',
                      style: TextStyles.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return _buildOrderCard(context, order);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('Order #${order.id.substring(0, 8)}'),
        subtitle: Text(
          '${order.items.length} items • Rs ${order.total.toStringAsFixed(2)}',
        ),
        trailing: _buildStatusChip(order.status),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.shippingAddress.fullName}',
                    style: TextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text('Email: ${order.shippingAddress.email}',
                    style: TextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text('Payment: ${order.paymentMethod.name}',
                    style: TextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text('Created: ${_formatDate(order.createdAt)}',
                    style: TextStyles.bodySmall),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Items:', style: TextStyles.labelLarge),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: TextStyles.bodySmall,
                      ),
                    )),
                const SizedBox(height: 16),
                _buildStatusActions(context, order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        color = AppColors.info;
        break;
      case OrderStatus.shipped:
        color = AppColors.primary;
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusActions(BuildContext context, OrderModel order) {
    if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      children: [
        if (order.status == OrderStatus.pending)
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(
                    UpdateOrderStatus(
                      orderId: order.id,
                      status: OrderStatus.confirmed,
                    ),
                  );
            },
            child: const Text('Confirm'),
          ),
        if (order.status == OrderStatus.confirmed)
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(
                    UpdateOrderStatus(
                      orderId: order.id,
                      status: OrderStatus.processing,
                    ),
                  );
            },
            child: const Text('Process'),
          ),
        if (order.status == OrderStatus.processing)
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(
                    UpdateOrderStatus(
                      orderId: order.id,
                      status: OrderStatus.shipped,
                    ),
                  );
            },
            child: const Text('Ship'),
          ),
        if (order.status == OrderStatus.shipped)
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(
                    UpdateOrderStatus(
                      orderId: order.id,
                      status: OrderStatus.delivered,
                    ),
                  );
            },
            child: const Text('Mark Delivered'),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

