import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:tree_store/core/error/failures.dart';
import 'package:tree_store/domain/entities/order.dart';
import 'package:tree_store/domain/entities/payment.dart';
import 'package:tree_store/domain/repositories/order_repository.dart';
import 'package:tree_store/domain/repositories/payment_repository.dart';
import 'package:tree_store/domain/usecases/order/create_order_usecase.dart';
import 'package:tree_store/domain/usecases/order/get_order_detail_usecase.dart';
import 'package:tree_store/domain/usecases/order/get_orders_usecase.dart';
import 'package:tree_store/domain/usecases/payment/create_payment_usecase.dart';
import 'package:tree_store/presentation/blocs/order_bloc.dart';

class _FakeOrderRepo implements OrderRepository {
  Order order;
  _FakeOrderRepo(this.order);
  @override
  Future<Either<Failure, List<Order>>> getOrders() async => Right([order]);
  @override
  Future<Either<Failure, Order>> getOrderDetail(String id) async => Right(order);
  @override
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
  }) async =>
      Right(order);
}

class _FakePaymentRepo implements PaymentRepository {
  @override
  Future<Either<Failure, PaymentInit>> createPayment({
    required String orderId,
    required String provider,
  }) async =>
      const Right(PaymentInit(
          paymentId: 'p1', orderCode: 123, checkoutUrl: 'https://pay.example/checkout'));
}

void main() {
  final baseOrder = Order(id: 'o1', totalPrice: 150000);

  OrderBloc buildBloc(_FakeOrderRepo repo) => OrderBloc(
        getOrders: GetOrdersUsecase(repo),
        getOrderDetail: GetOrderDetailUsecase(repo),
        createOrder: CreateOrderUsecase(repo),
        createPayment: CreatePaymentUsecase(_FakePaymentRepo()),
      );

  test('start payment emits PaymentReady with checkout url', () async {
    final bloc = buildBloc(_FakeOrderRepo(baseOrder));
    addTearDown(bloc.close);
    bloc.add(const OrderStartPayment('o1'));
    expect(
      await bloc.stream.firstWhere((s) => s is! OrderLoading),
      isA<PaymentReady>()
          .having((p) => p.checkoutUrl, 'checkoutUrl', 'https://pay.example/checkout'),
    );
  });

  test('watch payment emits PaymentPaid once order is paid', () async {
    final repo = _FakeOrderRepo(baseOrder);
    final bloc = buildBloc(repo);
    addTearDown(bloc.close);
    bloc.add(OrderWatchPayment('o1'));
    repo.order = Order(id: 'o1', totalPrice: 150000, paymentStatus: PaymentStatus.paid);
    final states = await bloc.stream
        .where((s) => s is PaymentPaid || s is PaymentTimeout)
        .take(1)
        .toList()
        .timeout(const Duration(seconds: 10));
    expect(states.single, isA<PaymentPaid>());
  });
}
