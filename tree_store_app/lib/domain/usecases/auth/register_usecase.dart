import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber];
}

class RegisterUsecase {
  final AuthRepository _repo;
  const RegisterUsecase(this._repo);

  Future<Either<Failure, User>> call(RegisterParams params) {
    if (params.email.isEmpty ||
        params.password.length < 6 ||
        params.fullName.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(
            'Email required, password >= 6 chars, name required')),
      );
    }
    return _repo.register(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
    );
  }
}