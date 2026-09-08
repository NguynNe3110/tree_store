import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository _repo;
  const UpdateProfileUsecase(this._repo);

  Future<Either<Failure, User>> call({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    if (fullName != null && fullName.isEmpty) {
      return Future.value(const Left(ValidationFailure('name cannot be empty')));
    }
    return _repo.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
    );
  }
}