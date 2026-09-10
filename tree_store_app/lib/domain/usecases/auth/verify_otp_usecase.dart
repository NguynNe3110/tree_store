import 'package:dartz/dartz.dart';
import 'package:tree_store/core/error/failures.dart';
import 'package:tree_store/domain/repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository _repository;
  VerifyOtpUsecase(this._repository);

  Future<Either<Failure, bool>> call({required String email, required String code, required String purpose}) async {
    return await _repository.verifyOtp(email: email, code: code, purpose: purpose);
  }
}
