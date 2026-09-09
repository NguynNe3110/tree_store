import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/cart_item.dart';
import '../../repositories/cart_repository.dart';

class GetCartUsecase {
  final CartRepository _repo;
  const GetCartUsecase(this._repo);

  Future<Either<Failure, List<CartItem>>> call() => _repo.getCart();
}
