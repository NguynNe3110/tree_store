import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repo;
  const LogoutUsecase(this._repo);

  Future<Either<Failure, void>> call() => _repo.logout();
}