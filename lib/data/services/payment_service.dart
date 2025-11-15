import 'dart:async';

import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';

import '../models/order_model.dart';

abstract class PaymentService {
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  });
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  PaymentResult({required this.success, this.transactionId, this.errorMessage});
}

class StripePaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (method == PaymentMethod.stripe) {
      return PaymentResult(
        success: true,
        transactionId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    return PaymentResult(
      success: false,
      errorMessage: 'Invalid payment method',
    );
  }
}

class PayPalPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (method == PaymentMethod.paypal) {
      return PaymentResult(
        success: true,
        transactionId: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    return PaymentResult(
      success: false,
      errorMessage: 'Invalid payment method',
    );
  }
}

class EsewaPaymentService implements PaymentService {
  EsewaPaymentService({EsewaConfig? config})
    : _defaultConfig = config ?? _EsewaCredentials.testConfig;

  final EsewaConfig _defaultConfig;

  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    if (method == PaymentMethod.esewa) {
      final completer = Completer<PaymentResult>();

      void safeComplete(PaymentResult result) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }

      try {
        final EsewaConfig config = EsewaConfig(
          clientId:
              (paymentData['clientId'] as String?) ?? _defaultConfig.clientId,
          secretId:
              (paymentData['secretId'] as String?) ?? _defaultConfig.secretId,
          environment:
              _parseEnvironment(paymentData['environment']) ??
              _defaultConfig.environment,
        );

        final String productId =
            (paymentData['productId'] as String?) ?? _generateProductId();
        final String productName =
            (paymentData['productName'] as String?) ??
            'Beauty & Cosmetics Order';
        final String callbackUrl =
            (paymentData['callbackUrl'] as String?)?.trim().isNotEmpty == true
            ? (paymentData['callbackUrl'] as String)
            : _defaultCallbackUrl;
        final String? ebpNo = paymentData['ebpNo'] as String?;

        EsewaFlutterSdk.initPayment(
          esewaConfig: config,
          esewaPayment: EsewaPayment(
            productId: productId,
            productName: productName,
            productPrice: _formatAmount(paymentData['amount'] ?? amount),
            callbackUrl: callbackUrl,
            ebpNo: ebpNo,
          ),
          onPaymentSuccess: (successResult) {
            safeComplete(
              PaymentResult(success: true, transactionId: successResult.refId),
            );
          },
          onPaymentFailure: (error) {
            safeComplete(
              PaymentResult(success: false, errorMessage: error.toString()),
            );
          },
          onPaymentCancellation: (message) {
            safeComplete(
              PaymentResult(
                success: false,
                errorMessage: 'Payment cancelled by user',
              ),
            );
          },
        );
      } catch (e) {
        safeComplete(PaymentResult(success: false, errorMessage: e.toString()));
      }

      return completer.future;
    }

    return PaymentResult(
      success: false,
      errorMessage: 'Invalid payment method',
    );
  }
}

class KhaltiPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (method == PaymentMethod.khalti) {
    
      return PaymentResult(
        success: true,
        transactionId: 'khalti_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    return PaymentResult(
      success: false,
      errorMessage: 'Invalid payment method',
    );
  }
}

class CashOnDeliveryPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    // Cash on delivery doesn't require payment processing
    // Payment will be collected upon delivery
    if (method == PaymentMethod.cashOnDelivery) {
      return PaymentResult(
        success: true,
        transactionId: 'cod_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    return PaymentResult(
      success: false,
      errorMessage: 'Invalid payment method',
    );
  }
}

class PaymentServiceFactory {
  static PaymentService getService(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.stripe:
        return StripePaymentService();
      case PaymentMethod.paypal:
        return PayPalPaymentService();
      case PaymentMethod.esewa:
        return EsewaPaymentService();
      case PaymentMethod.khalti:
        return KhaltiPaymentService();
      case PaymentMethod.cashOnDelivery:
        return CashOnDeliveryPaymentService();
    }
  }
}

String _formatAmount(dynamic amount) {
  if (amount is num) {
    return amount.toStringAsFixed(2);
  }
  if (amount is String) {
    return amount;
  }
  throw ArgumentError('Unsupported amount type for eSewa payment: $amount');
}

Environment? _parseEnvironment(dynamic raw) {
  if (raw == null) return null;
  final value = raw.toString().toLowerCase();
  if (value == 'live' || value == 'environment.live') return Environment.live;
  if (value == 'test' || value == 'environment.test') return Environment.test;
  return null;
}

String _generateProductId() => 'ORDER-${DateTime.now().millisecondsSinceEpoch}';

const String _defaultCallbackUrl = 'https://example.com/esewa-callback';

class _EsewaCredentials {
  static const String _testClientId =
      'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R';
  static const String _testSecretKey =
      'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==';

  static EsewaConfig get testConfig => EsewaConfig(
    clientId: _testClientId,
    secretId: _testSecretKey,
    environment: Environment.test,
  );
}
