part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  final String userId;

  const LoadOrders(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateOrder extends OrdersEvent {
  final OrderModel order;
  final Map<String, dynamic> paymentData;

  const CreateOrder({
    required this.order,
    required this.paymentData,
  });

  @override
  List<Object?> get props => [order, paymentData];
}

class UpdateOrderStatus extends OrdersEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatus({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

