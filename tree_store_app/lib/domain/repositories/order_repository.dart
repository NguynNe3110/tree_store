import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../entities/order.dart';

class OrderItemInput extends Equatable {
  final String treeId;
  final int quantity;
  const OrderItemInput({required this.treeId, required this.quantity});

  @override
  List<Object?> get props => [treeId, quantity];
}

abstract class OrderRepository {
  Future<Either<Failure, List<Order>>> getOrders();
  Future<Either<Failure, Order>> getOrderDetail(String id);
  Future<Either<Failure, Order>> createOrder({
    required String customerName,
    required String phoneNumber,
    required String addressLine,
    String city = '',
    String district = '',
    String? ward,
    String? note,
    required List<OrderItemInput> items,
    String paymentMethod = 'cod',
    double shippingFee = 0,
    double discountAmount = 0,
  });
}