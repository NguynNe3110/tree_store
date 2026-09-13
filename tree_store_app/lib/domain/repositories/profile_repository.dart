import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/address.dart';
import '../entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  });
  Future<Either<Failure, String>> uploadAvatar(String filePath);
  Future<Either<Failure, List<Address>>> getAddresses();
  Future<Either<Failure, String>> addAddress({
    String? label,
    required String receiverName,
    required String phoneNumber,
    required String addressLine,
    required String city,
    required String district,
    String? ward,
    String? postalCode,
    bool isDefault = false,
  });
}