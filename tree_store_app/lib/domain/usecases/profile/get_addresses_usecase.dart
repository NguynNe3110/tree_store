import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/address.dart';
import '../../repositories/profile_repository.dart';

class GetAddressesUsecase {
  final ProfileRepository _repo;
  const GetAddressesUsecase(this._repo);

  Future<Either<Failure, List<Address>>> call() => _repo.getAddresses();
}