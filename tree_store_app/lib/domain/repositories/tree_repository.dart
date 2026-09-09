import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/category.dart';
import '../entities/product.dart';

abstract class TreeRepository {
  Future<Either<Failure, List<Product>>> getTrees({
    String? categoryId,
    String? keyword,
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Product>> getTreeDetail(String id);

  Future<Either<Failure, List<Category>>> getCategories();
}