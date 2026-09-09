import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../entities/product.dart';
import '../../repositories/tree_repository.dart';

class GetTreesParams extends Equatable {
  final String? categoryId;
  final String? keyword;
  final String? status;
  final int page;
  final int limit;
  const GetTreesParams({
    this.categoryId,
    this.keyword,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [categoryId, keyword, status, page, limit];
}

class GetTreesUsecase {
  final TreeRepository _repo;
  const GetTreesUsecase(this._repo);

  Future<Either<Failure, List<Product>>> call(GetTreesParams params) =>
      _repo.getTrees(
        categoryId: params.categoryId,
        keyword: params.keyword,
        status: params.status,
        page: params.page,
        limit: params.limit,
      );
}