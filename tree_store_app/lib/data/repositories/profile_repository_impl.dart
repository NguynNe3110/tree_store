import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../mappers/address_mapper.dart';
import '../mappers/user_mapper.dart';
import '../remote/datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final dto = await _remote.getProfile();
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final dto = await _remote.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async {
    try {
      final dtos = await _remote.getAddresses();
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final id = await _remote.addAddress(
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
      return Right(id);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

Failure _mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode ?? 0;
      return ServerFailure(e.response?.data?['message']?.toString() ?? 'Server error $code');
    default:
      return ServerFailure(e.message ?? 'Unknown error');
  }
}