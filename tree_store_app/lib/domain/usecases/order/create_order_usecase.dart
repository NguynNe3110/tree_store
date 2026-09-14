import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class CreateOrderParams extends Equatable {
  final String customerName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String district;
  final String? ward;
  final String? note;
  final List<OrderItemInput> items;
  final String paymentMethod;
  final double shippingFee;
  final double discountAmount;
  const CreateOrderParams({
    required this.customerName,
    required this.phoneNumber,
    required this.addressLine,
    this.city = '',
    this.district = '',
    this.ward,
    this.note,
    required this.items,
    this.paymentMethod = 'cod',
    this.shippingFee = 0,
    this.discountAmount = 0,
  });

  @override
  List<Object?> get props => [
        customerName,
        phoneNumber,
        addressLine,
        city,
        district,
        ward,
        note,
        items,
        paymentMethod,
        shippingFee,
        discountAmount,
      ];
}

class CreateOrderUsecase {
  final OrderRepository _repo;
  const CreateOrderUsecase(this._repo);

  Future<Either<Failure, Order>> call(CreateOrderParams params) {
    if (params.customerName.isEmpty ||
        params.phoneNumber.isEmpty ||
        params.items.isEmpty) {
      return Future.value(const Left(ValidationFailure(
          'customerName, phoneNumber and items required')));
    }
    return _repo.createOrder(
      customerName: params.customerName,
      phoneNumber: params.phoneNumber,
      addressLine: params.addressLine,
      note: params.note,
      items: params.items,
      paymentMethod: params.paymentMethod,
      shippingFee: params.shippingFee,
      discountAmount: params.discountAmount,
    );
  }
}