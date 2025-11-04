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

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
  });
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
    
    // Mock implementation - In production, integrate with Stripe SDK
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
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (method == PaymentMethod.esewa) {
      // In production, integrate with eSewa SDK
      return PaymentResult(
        success: true,
        transactionId: 'esewa_${DateTime.now().millisecondsSinceEpoch}',
      );
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
      // In production, integrate with Khalti SDK
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
      default:
        return StripePaymentService();
    }
  }
}

