import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/remote/models/responses/home_response.dart';
import '../repositories/home_repository.dart';

class GetHomeBlocksUsecase {
  final HomeRepository _repository;
  GetHomeBlocksUsecase(this._repository);

  Future<Either<Failure, HomeSduiResponse>> call() async {
    return await _repository.getHomeBlocks();
  }
}
