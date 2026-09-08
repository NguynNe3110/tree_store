import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository _repo;
  const GetProfileUsecase(this._repo);

  Future<Either<Failure, User>> call() => _repo.getProfile();
}