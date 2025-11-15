import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/orders/orders_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/order_model.dart';
import '../../../payment/presentation/pages/esewa_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.stripe;
  bool _isProcessing = false;

  static const double _deliveryCharge = 5.0;
  static const double _taxRate = 0.1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTax(double subtotal) => subtotal * _taxRate;

  double _calculateTotal(CartState cartState) {
    final subtotal = cartState.totalPrice;
    final delivery = _deliveryCharge;
    final tax = _calculateTax(subtotal);
    return subtotal + delivery + tax;
  }

  String _formatCurrency(double amount) => 'Rs ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            setState(() => _isProcessing = false);
            context.read<CartBloc>().add(const ClearCart());
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is OrdersError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your cart is empty', style: TextStyles.h5),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Continue Shopping',
                      onPressed: () => context.go('/'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInfo(),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(cartState),
                    const SizedBox(height: 24),
                    _buildOrderSummary(cartState),
                    const SizedBox(height: 24),
                    _buildPlaceOrderButton(cartState),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Details', style: TextStyles.h5),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: '',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email', hintText: ''),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Delivery Notes (Optional)',
            hintText: 'e.g. Leave at reception',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: TextStyles.h5),
        const SizedBox(height: 16),
        DropdownButtonFormField<PaymentMethod>(
          value: _selectedPaymentMethod,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Select Payment Method',
          ),
          items: PaymentMethod.values
              .map(
                (method) => DropdownMenuItem(
                  value: method,
                  child: Text(_getPaymentMethodName(method)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedPaymentMethod = value;
            });

            if (value == PaymentMethod.esewa) {
              final total = _calculateTotal(cartState);
              final productId =
                  'ORDER-${DateTime.now().millisecondsSinceEpoch}';

              context.pushNamed(
                'esewa-payment',
                extra: EsewaPaymentArguments(
                  amount: total,
                  paymentData: {
                    'amount': total,
                    'currency': 'NPR',
                    'productId': productId,
                    'productName': 'Beauty & Cosmetics Order',
                    'callbackUrl': 'https://example.com/esewa-callback',
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.stripe:
        return 'Credit/Debit Card (Stripe)';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.esewa:
        return 'eSewa';
      case PaymentMethod.khalti:
        return 'Khalti';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  Widget _buildOrderSummary(CartState cartState) {
    final subtotal = cartState.totalPrice;
    final delivery = _deliveryCharge;
    final tax = _calculateTax(subtotal);
    final total = subtotal + delivery + tax;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: TextStyles.h5),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyles.bodyMedium),
                Text(_formatCurrency(subtotal), style: TextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Charge', style: TextStyles.bodyMedium),
                Text(_formatCurrency(delivery), style: TextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax', style: TextStyles.bodyMedium),
                Text(_formatCurrency(tax), style: TextStyles.bodyMedium),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyles.h5),
                Text(_formatCurrency(total), style: TextStyles.price),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartState cartState) {
    final subtotal = cartState.totalPrice;
    final delivery = _deliveryCharge;
    final tax = _calculateTax(subtotal);
    final total = subtotal + delivery + tax;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState is AuthAuthenticated
            ? authState.user.id
            : 'guest_${DateTime.now().millisecondsSinceEpoch}';

        return CustomButton(
          text: 'Place Order',
          onPressed: _isProcessing
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isProcessing = true);
                    final shippingAddress = ShippingAddress(
                      fullName: _nameController.text,
                      phone: _phoneController.text,
                      email: _emailController.text,
                      addressLine1: _notesController.text.isNotEmpty
                          ? _notesController.text
                          : 'Not provided',
                      city: '',
                    );

                    final order = OrderModel(
                      id: '',
                      userId: userId,
                      items: cartState.items,
                      subtotal: subtotal,
                      shippingCost: delivery,
                      tax: tax,
                      total: total,
                      status: OrderStatus.pending,
                      paymentMethod: _selectedPaymentMethod,
                      paymentStatus: PaymentStatus.pending,
                      createdAt: DateTime.now(),
                      shippingAddress: shippingAddress,
                    );

                    final paymentData = {'amount': total, 'currency': 'NPR'};

                    if (_selectedPaymentMethod == PaymentMethod.esewa) {
                      paymentData.addAll({
                        'productId':
                            'ORDER-${DateTime.now().millisecondsSinceEpoch}',
                        'productName': 'Beauty & Cosmetics Order',
                        'callbackUrl': 'https://example.com/esewa-callback',
                      });
                    }

                    context.read<OrdersBloc>().add(
                      CreateOrder(order: order, paymentData: paymentData),
                    );
                  }
                },
          isFullWidth: true,
          isLoading: _isProcessing,
          type: ButtonType.primary,
        );
      },
    );
  }
}
