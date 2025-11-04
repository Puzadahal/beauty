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
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController(text: 'United States');

  PaymentMethod _selectedPaymentMethod = PaymentMethod.stripe;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderCreated) {
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
                    Text(
                      'Your cart is empty',
                      style: TextStyles.h5,
                    ),
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
                    _buildShippingInfo(),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(),
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

  Widget _buildShippingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping Information', style: TextStyles.h5),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
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
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'john@example.com',
          ),
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
            hintText: '+1 234 567 8900',
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
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address Line 1',
            hintText: '123 Main Street',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'New York',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  hintText: 'NY',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _zipController,
                decoration: const InputDecoration(
                  labelText: 'ZIP Code',
                  hintText: '10001',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ZIP code';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter country';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: TextStyles.h5),
        const SizedBox(height: 16),
        ...PaymentMethod.values.map((method) {
          return RadioListTile<PaymentMethod>(
            title: Text(_getPaymentMethodName(method)),
            value: method,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          );
        }),
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
    final shipping = 5.00;
    final tax = subtotal * 0.1;
    final total = subtotal + shipping + tax;

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
                Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: TextStyles.bodyMedium),
                Text('\$${shipping.toStringAsFixed(2)}', style: TextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax', style: TextStyles.bodyMedium),
                Text('\$${tax.toStringAsFixed(2)}', style: TextStyles.bodyMedium),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyles.h5),
                Text('\$${total.toStringAsFixed(2)}', style: TextStyles.price),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartState cartState) {
    final subtotal = cartState.totalPrice;
    final shipping = 5.00;
    final tax = subtotal * 0.1;
    final total = subtotal + shipping + tax;

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
                      addressLine1: _addressController.text,
                      city: _cityController.text,
                      state: _stateController.text,
                      zipCode: _zipController.text,
                      country: _countryController.text,
                    );

                    final order = OrderModel(
                      id: '',
                      userId: userId,
                      items: cartState.items,
                      subtotal: subtotal,
                      shippingCost: shipping,
                      tax: tax,
                      total: total,
                      status: OrderStatus.pending,
                      paymentMethod: _selectedPaymentMethod,
                      paymentStatus: PaymentStatus.pending,
                      createdAt: DateTime.now(),
                      shippingAddress: shippingAddress,
                    );

                    context.read<OrdersBloc>().add(
                          CreateOrder(
                            order: order,
                            paymentData: {
                              'amount': total,
                              'currency': 'USD',
                            },
                          ),
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

