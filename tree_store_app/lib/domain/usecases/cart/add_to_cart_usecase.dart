import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/cart_repository.dart';

class AddToCartUsecase {
  final CartRepository _repo;
  const AddToCartUsecase(this._repo);

  Future<Either<Failure, void>> call({required String treeId, int quantity = 1, String? note}) =>
      _repo.addToCart(treeId: treeId, quantity: quantity, note: note);
}