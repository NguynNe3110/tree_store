import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/cart/get_cart_usecase.dart';
import '../../domain/usecases/cart/add_to_cart_usecase.dart';
import '../../domain/usecases/cart/remove_from_cart_usecase.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
}

class CartLoad extends CartEvent {
  const CartLoad();
  @override
  List<Object?> get props => [];
}

class CartAdd extends CartEvent {
  final String treeId;
  final int quantity;
  const CartAdd(this.treeId, [this.quantity = 1]);
  @override
  List<Object?> get props => [treeId, quantity];
}

class CartRemove extends CartEvent {
  final String id;
  const CartRemove(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class CartState extends Equatable {
  const CartState();
}

class CartInitial extends CartState {
  const CartInitial();
  @override
  List<Object?> get props => [];
}

class CartLoading extends CartState {
  const CartLoading();
  @override
  List<Object?> get props => [];
}

class CartLoaded extends CartState {
  final List<CartItem> items;
  const CartLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUsecase _getCart;
  final AddToCartUsecase _addToCart;
  final RemoveFromCartUsecase _removeFromCart;

  CartBloc({
    required GetCartUsecase getCart,
    required AddToCartUsecase addToCart,
    required RemoveFromCartUsecase removeFromCart,
  })  : _getCart = getCart,
        _addToCart = addToCart,
        _removeFromCart = removeFromCart,
        super(const CartInitial()) {
    on<CartLoad>(_onLoad);
    on<CartAdd>(_onAdd);
    on<CartRemove>(_onRemove);
  }

  Future<void> _onLoad(CartLoad event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    final result = await _getCart();
    result.fold(
      (f) => emit(CartError(f.message)),
      (items) => emit(CartLoaded(items)),
    );
  }

  Future<void> _onAdd(CartAdd event, Emitter<CartState> emit) async {
    await _addToCart(treeId: event.treeId, quantity: event.quantity);
    add(const CartLoad());
  }

  Future<void> _onRemove(CartRemove event, Emitter<CartState> emit) async {
    await _removeFromCart(event.id);
    add(const CartLoad());
  }
}