import 'package:dartz/dartz.dart';
import 'package:tree_store/core/error/failures.dart';
import 'package:tree_store/domain/repositories/auth_repository.dart';

class SendOtpUsecase {
  final AuthRepository _repository;
  SendOtpUsecase(this._repository);

  Future<Either<Failure, void>> call({required String email, required String purpose}) async {
    return await _repository.sendOtp(email: email, purpose: purpose);
  }
}
