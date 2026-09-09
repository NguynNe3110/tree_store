import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/cart_repository.dart';

class RemoveFromCartUsecase {
  final CartRepository _repo;
  const RemoveFromCartUsecase(this._repo);

  Future<Either<Failure, void>> call(String id) => _repo.removeFromCart(id);
}