import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/product.dart';
import '../../repositories/tree_repository.dart';

class GetFeaturedTreesUsecase {
  final TreeRepository _repo;
  const GetFeaturedTreesUsecase(this._repo);

  Future<Either<Failure, List<Product>>> call() => _repo.getFeaturedTrees();
}