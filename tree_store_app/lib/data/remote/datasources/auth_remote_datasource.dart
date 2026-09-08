import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/requests/auth_request.dart';
import '../models/responses/user_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<UserResponseDto> login(String email, String password) async {
    final res = await _dio.post(
      ApiEndpoints.login,
      data: LoginRequestDto(email: email, password: password).toJson(),
    );
    return UserResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserResponseDto> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.register,
      data: RegisterRequestDto(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      ).toJson(),
    );
    return UserResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }
}