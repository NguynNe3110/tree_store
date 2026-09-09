import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/remote/models/responses/home_response.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeSduiResponse>> getHomeBlocks();
}
