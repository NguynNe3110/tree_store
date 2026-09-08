import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../remote/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.login(email, password);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final dto = await _remote.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
      return const Right(null);
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
      if (code == 401 || code == 403) {
        return AuthFailure(e.response?.data?['message']?.toString() ?? 'Auth failed');
      }
      return ServerFailure(e.response?.data?['message']?.toString() ?? 'Server error $code');
    default:
      return ServerFailure(e.message ?? 'Unknown error');
  }
}