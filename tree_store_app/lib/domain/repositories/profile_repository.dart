import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  });
}