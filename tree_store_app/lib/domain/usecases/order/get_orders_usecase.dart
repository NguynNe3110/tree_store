import 'package:dartz/dartz.dart' hide Order;
import '../../../core/error/failures.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class GetOrdersUsecase {
  final OrderRepository _repo;
  const GetOrdersUsecase(this._repo);

  Future<Either<Failure, List<Order>>> call() => _repo.getOrders();
}