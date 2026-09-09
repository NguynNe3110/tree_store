import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository _repository;
  VerifyOtpUsecase(this._repository);

  Future<Either<Failure, bool>> call({required String email, required String code, required String purpose}) async {
    return await _repository.verifyOtp(email: email, code: code, purpose: purpose);
  }
}
