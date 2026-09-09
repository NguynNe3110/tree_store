import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/order/get_orders_usecase.dart';
import '../../domain/usecases/order/create_order_usecase.dart';

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

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUsecase _getOrders;
  final CreateOrderUsecase _createOrder;

  OrderBloc({required GetOrdersUsecase getOrders, required CreateOrderUsecase createOrder})
      : _getOrders = getOrders,
        _createOrder = createOrder,
        super(const OrderInitial()) {
    on<OrderLoadAll>(_onLoadAll);
    on<OrderCreate>(_onCreate);
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
}