import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/product.dart';
import '../../repositories/tree_repository.dart';

class GetTreeDetailUsecase {
  final TreeRepository _repo;
  const GetTreeDetailUsecase(this._repo);

  Future<Either<Failure, Product>> call(String id) {
    if (id.isEmpty) {
      return Future.value(const Left(ValidationFailure('treeId required')));
    }
    return _repo.getTreeDetail(id);
  }
}