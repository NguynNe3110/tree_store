import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/profile_repository.dart';

class AddAddressUsecase {
  final ProfileRepository _repo;
  const AddAddressUsecase(this._repo);

  Future<Either<Failure, String>> call({
    String? label,
    required String receiverName,
    required String phoneNumber,
    required String addressLine,
    required String city,
    required String district,
    String? ward,
    String? postalCode,
    bool isDefault = false,
  }) =>
      _repo.addAddress(
        label: label,
        receiverName: receiverName,
        phoneNumber: phoneNumber,
        addressLine: addressLine,
        city: city,
        district: district,
        ward: ward,
        postalCode: postalCode,
        isDefault: isDefault,
      );
}