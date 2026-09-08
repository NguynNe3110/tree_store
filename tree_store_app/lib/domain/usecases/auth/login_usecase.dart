import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUsecase {
  final AuthRepository _repo;
  const LoginUsecase(this._repo);

  Future<Either<Failure, User>> call(LoginParams params) {
    if (params.email.isEmpty || params.password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Email and password are required')),
      );
    }
    return _repo.login(email: params.email, password: params.password);
  }
}