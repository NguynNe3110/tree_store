import 'package:dartz/dartz.dart';
import 'package:tree_store/core/error/failures.dart';
import 'package:tree_store/data/remote/models/responses/home_response.dart';
import 'package:tree_store/domain/repositories/home_repository.dart';

class GetHomeBlocksUsecase {
  final HomeRepository _repository;
  GetHomeBlocksUsecase(this._repository);

  Future<Either<Failure, HomeSduiResponse>> call({String? categoryId}) async {
    return await _repository.getHomeBlocks(categoryId: categoryId);
  }
}
