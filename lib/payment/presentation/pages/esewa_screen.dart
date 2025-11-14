import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/order_model.dart';
import '../../../data/services/payment_service.dart';

class EsewaPaymentArguments {
  const EsewaPaymentArguments({
    required this.amount,
    this.paymentData,
  });

  final double amount;
  final Map<String, dynamic>? paymentData;
}

class EsewaScreen extends StatefulWidget {
  const EsewaScreen({
    super.key,
    required this.amount,
    this.paymentData,
  });

  final double amount;
  final Map<String, dynamic>? paymentData;

  @override
  State<EsewaScreen> createState() => _EsewaScreenState();
}

class _EsewaScreenState extends State<EsewaScreen> {
  bool _isProcessing = false;
  String? _statusMessage;

  double get _resolvedAmount => widget.amount > 0 ? widget.amount : 20.0;

  Future<void> _startPayment() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = null;
    });

    final paymentService = PaymentServiceFactory.getService(
      PaymentMethod.esewa,
    );
    final amount = _resolvedAmount;
    final productId =
        (widget.paymentData?['productId'] as String?) ??
            'ORDER-${DateTime.now().millisecondsSinceEpoch}';

    try {
      final Map<String, dynamic> paymentData = {
        'productId': productId,
        'productName': widget.paymentData?['productName'] as String? ??
            'Beauty & Cosmetics Order',
        'amount': widget.paymentData?['amount'] ?? amount,
        'callbackUrl': widget.paymentData?['callbackUrl'] ??
            'https://example.com/esewa-callback',
        'clientId': widget.paymentData?['clientId'],
        'secretId': widget.paymentData?['secretId'],
        'environment': widget.paymentData?['environment'],
        'ebpNo': widget.paymentData?['ebpNo'],
      };

      final result = await paymentService.processPayment(
        amount: amount,
        method: PaymentMethod.esewa,
        paymentData: paymentData,
      );

      if (result.success) {
        // Navigate to homepage and show success dialog
        if (mounted) {
          final transactionId = result.transactionId;
          
          // Navigate to homepage 
          context.go('/');
          
          // Show success dialog after navigation completes
          // Use WidgetsBinding to ensure we have a valid context after navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              // Show dialog using root navigator to display on the new route
              showDialog(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Payment Successful'),
                    content: Text(
                      'Your payment has been processed successfully.\n'
                      'Reference: ${transactionId ?? 'N/A'}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            });
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Payment failed: ${result.errorMessage ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Payment error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('eSewa Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
           
            Text(
              'Amount to pay: Rs ${_resolvedAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _startPayment,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Pay with eSewa (Rs ${_resolvedAmount.toStringAsFixed(2)})'),
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
