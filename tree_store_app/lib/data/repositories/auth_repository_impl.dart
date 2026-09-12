import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../core/network/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../remote/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[DEBUG] AuthRepositoryImpl.login called, email: $email');
    try {
      final dto = await _remote.login(email, password);
      debugPrint('[DEBUG] AuthRepositoryImpl.login success, userId: ${dto.userId}');
      await _tokenStorage.saveTokens(dto.token, dto.refreshToken);
      return Right(User(id: dto.userId, fullName: '')); // ponytail: login response has no fullName/email, fetch profile after login to populate. upgrade when UI needs it
    } on DioException catch (e) {
      debugPrint('[DEBUG] AuthRepositoryImpl.login DioException: ${e.response?.statusCode} ${e.message}');
      return Left(_mapDioError(e));
    } catch (e) {
      debugPrint('[DEBUG] AuthRepositoryImpl.login error: $e');
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
    debugPrint('[DEBUG] AuthRepositoryImpl.register called, email: $email');
    try {
      final dto = await _remote.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      debugPrint('[DEBUG] AuthRepositoryImpl.register success, userId: ${dto.userId}, token empty: ${dto.token.isEmpty}');
      await _tokenStorage.saveTokens(dto.token, dto.refreshToken);
      return Right(User(id: dto.userId, fullName: fullName));
    } on DioException catch (e) {
      debugPrint('[DEBUG] AuthRepositoryImpl.register DioException: ${e.response?.statusCode} ${e.message}');
      return Left(_mapDioError(e));
    } catch (e) {
      debugPrint('[DEBUG] AuthRepositoryImpl.register error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
      await _tokenStorage.clear();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({required String email, required String purpose}) async {
    try {
      await _remote.sendOtp(email, purpose);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({required String email, required String code, required String purpose}) async {
    try {
      final result = await _remote.verifyOtp(email, code, purpose);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _remote.forgotPassword(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email, required String code, required String newPassword}) async {
    try {
      await _remote.resetPassword(email, code, newPassword);
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