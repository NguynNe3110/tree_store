import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/profile_repository.dart';

class UploadAvatarUsecase {
  final ProfileRepository _repo;
  const UploadAvatarUsecase(this._repo);

  Future<Either<Failure, String>> call(String filePath) => _repo.uploadAvatar(filePath);
}