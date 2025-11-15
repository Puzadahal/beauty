import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/payment_service.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final ApiService apiService;

  OrdersBloc({
    required this.apiService,
  }) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orders = await apiService.getOrders(event.userId);
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      // Process payment first (skip for cash on delivery)
      PaymentStatus paymentStatus = PaymentStatus.pending;
      
      if (event.order.paymentMethod != PaymentMethod.cashOnDelivery) {
        final paymentService = PaymentServiceFactory.getService(event.order.paymentMethod);
        final paymentResult = await paymentService.processPayment(
          amount: event.order.total,
          method: event.order.paymentMethod,
          paymentData: event.paymentData,
        );

        if (!paymentResult.success) {
          emit(OrdersError(message: paymentResult.errorMessage ?? 'Payment failed'));
          return;
        }
        
        paymentStatus = PaymentStatus.completed;
      }

      // Create order with payment status
      final orderWithPayment = event.order.copyWith(
        paymentStatus: paymentStatus,
      );

      final createdOrder = await apiService.createOrder(orderWithPayment);
      if (createdOrder != null) {
        emit(OrderCreated(order: createdOrder));
      } else {
        emit(OrdersError(message: 'Failed to create order'));
      }
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final updatedOrder = await apiService.updateOrderStatus(
        event.orderId,
        event.status,
      );
      if (updatedOrder != null) {
        emit(OrderUpdated(order: updatedOrder));
      }
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }
}

