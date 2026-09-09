import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart();
  Future<Either<Failure, void>> addToCart({required String treeId, int quantity = 1, String? note});
  Future<Either<Failure, void>> removeFromCart(String id);
}