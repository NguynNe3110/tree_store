import 'package:dartz/dartz.dart' hide Order;
import '../../../core/error/failures.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

class GetOrderDetailUsecase {
  final OrderRepository _repo;
  const GetOrderDetailUsecase(this._repo);

  Future<Either<Failure, Order>> call(String orderId) {
    if (orderId.isEmpty) {
      return Future.value(const Left(ValidationFailure('orderId required')));
    }
    return _repo.getOrderDetail(orderId);
  }
}
