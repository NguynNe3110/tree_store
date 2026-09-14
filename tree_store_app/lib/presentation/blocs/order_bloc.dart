import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/order/get_orders_usecase.dart';
import '../../domain/usecases/order/get_order_detail_usecase.dart';
import '../../domain/usecases/order/create_order_usecase.dart';
import '../../domain/usecases/payment/create_payment_usecase.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class OrderLoadAll extends OrderEvent {
  const OrderLoadAll();
  @override
  List<Object?> get props => [];
}

class OrderCreate extends OrderEvent {
  final CreateOrderParams params;
  const OrderCreate(this.params);
  @override
  List<Object?> get props => [params];
}

class OrderStartPayment extends OrderEvent {
  final String orderId;
  const OrderStartPayment(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

// Poll GET /api/orders/:id sau khi user quay về từ webview.
// Webhook server-side la nguon su that; khong tin ket qua redirect phia client.
class OrderWatchPayment extends OrderEvent {
  final String orderId;
  const OrderWatchPayment(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

abstract class OrderState extends Equatable {
  const OrderState();
}

class OrderInitial extends OrderState {
  const OrderInitial();
  @override
  List<Object?> get props => [];
}

class OrderLoading extends OrderState {
  const OrderLoading();
  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderCreated extends OrderState {
  final Order order;
  const OrderCreated(this.order);
  @override
  List<Object?> get props => [order];
}

class PaymentReady extends OrderState {
  final String orderId;
  final String checkoutUrl;
  const PaymentReady({required this.orderId, required this.checkoutUrl});
  @override
  List<Object?> get props => [orderId, checkoutUrl];
}

class PaymentPaid extends OrderState {
  final Order order;
  const PaymentPaid(this.order);
  @override
  List<Object?> get props => [order];
}

class PaymentTimeout extends OrderState {
  const PaymentTimeout();
  @override
  List<Object?> get props => [];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUsecase _getOrders;
  final GetOrderDetailUsecase _getOrderDetail;
  final CreateOrderUsecase _createOrder;
  final CreatePaymentUsecase _createPayment;

  static const pollInterval = Duration(seconds: 2);
  static const pollTimeout = Duration(seconds: 60);

  OrderBloc({
    required GetOrdersUsecase getOrders,
    required GetOrderDetailUsecase getOrderDetail,
    required CreateOrderUsecase createOrder,
    required CreatePaymentUsecase createPayment,
  })  : _getOrders = getOrders,
        _getOrderDetail = getOrderDetail,
        _createOrder = createOrder,
        _createPayment = createPayment,
        super(const OrderInitial()) {
    on<OrderLoadAll>(_onLoadAll);
    on<OrderCreate>(_onCreate);
    on<OrderStartPayment>(_onStartPayment);
    on<OrderWatchPayment>(_onWatchPayment);
  }

  Future<void> _onLoadAll(OrderLoadAll event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    final result = await _getOrders();
    result.fold(
      (f) => emit(OrderError(f.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> _onCreate(OrderCreate event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    final result = await _createOrder(event.params);
    result.fold(
      (f) => emit(OrderError(f.message)),
      (order) => emit(OrderCreated(order)),
    );
  }

  Future<void> _onStartPayment(
      OrderStartPayment event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    final result =
        await _createPayment(orderId: event.orderId, provider: 'payos');
    result.fold(
      (f) => emit(OrderError(f.message)),
      (p) => emit(PaymentReady(orderId: event.orderId, checkoutUrl: p.checkoutUrl)),
    );
  }

  Future<void> _onWatchPayment(
      OrderWatchPayment event, Emitter<OrderState> emit) async {
    final deadline = DateTime.now().add(pollTimeout);
    await emit.forEach<OrderState>(
      _pollStream(event.orderId, deadline),
      onData: (s) => s,
    );
  }

  Stream<OrderState> _pollStream(String orderId, DateTime deadline) async* {
    yield const OrderLoading();
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(pollInterval);
      final result = await _getOrderDetail(orderId);
      final Order? order = result.fold((_) => null, (o) => o);
      if (order != null && order.paymentStatus == PaymentStatus.paid) {
        yield PaymentPaid(order);
        return;
      }
    }
    yield const PaymentTimeout();
  }
}
