import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/orders/orders_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../../data/services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return _buildProfileContent(context, authState.user);
          }
          return _buildGuestProfile(context);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        Responsive.getResponsiveValue(
          context,
          mobile: 16,
          tablet: 24,
          desktop: 32,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          _buildProfileSection(
            context,
            title: 'Personal Information',
            children: [
              _buildInfoTile(
                context,
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              _buildInfoTile(
                context,
                icon: Icons.person_outline,
                label: 'Name',
                value: user.name ?? 'Not set',
              ),
              _buildInfoTile(
                context,
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone ?? 'Not set',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            context,
            title: 'Order History',
            children: [
              BlocProvider(
                create: (context) =>
                    OrdersBloc(apiService: ApiService())
                      ..add(LoadOrders(user.id)),
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state is OrdersLoaded) {
                      if (state.orders.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No orders yet',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: state.orders.take(5).map((order) {
                          return _buildOrderTile(context, order);
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            context,
            title: 'Account Actions',
            children: [
              _buildActionTile(
                context,
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              const LogoutRequested(),
                            );
                            Navigator.pop(context);
                            context.go('/login');
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Please login to view your profile',
              style: TextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Login to access your orders and account information',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Login',
              onPressed: () => context.go('/login'),
              isFullWidth: true,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final double avatarRadius = Responsive.getResponsiveValue(
      context,
      mobile: 40,
      tablet: 50,
      desktop: 60,
    );

    final double editRadius = avatarRadius * 0.35;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          Responsive.getResponsiveValue(
            context,
            mobile: 16,
            tablet: 24,
            desktop: 32,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: avatarRadius,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: CircleAvatar(
                      radius: editRadius,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: editRadius - 2,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name ?? 'User',
              style: TextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (user.isAdmin) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ADMIN',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: TextStyles.h5),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: TextStyles.bodySmall),
      subtitle: Text(value, style: TextStyles.bodyMedium),
      trailing: value == 'Not set'
          ? TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile coming soon!')),
                );
              },
              child: const Text('Edit'),
            )
          : null,
    );
  }

  Widget _buildOrderTile(BuildContext context, order) {
    return ListTile(
      leading: const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.primary,
      ),
      title: Text(
        'Order #${order.id.substring(0, 8)}',
        style: TextStyles.bodyMedium,
      ),
      subtitle: Text(
        '${order.items.length} items • Rs ${order.total.toStringAsFixed(2)}',
        style: TextStyles.bodySmall,
      ),
      trailing: Chip(
        label: Text(
          order.status.name.toUpperCase(),
          style: TextStyles.labelSmall.copyWith(
            color: _getStatusColor(order.status),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
      ),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order details coming soon!')));
      },
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.error),
      title: Text(
        title,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.error),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Color _getStatusColor(status) {
    switch (status.name) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
      case 'processing':
        return AppColors.info;
      case 'shipped':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
