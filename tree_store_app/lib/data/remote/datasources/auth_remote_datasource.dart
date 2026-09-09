import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/requests/auth_request.dart';
import '../models/responses/auth_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<AuthResponseDto> login(String email, String password) async {
    final res = await _dio.post(
      ApiEndpoints.login,
      data: LoginRequestDto(email: email, password: password).toJson(),
    );
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponseDto> register({
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
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponseDto> refreshToken(String refreshToken) async {
    final res = await _dio.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  Future<void> sendOtp(String email, String purpose) async {
    await _dio.post(
      ApiEndpoints.sendOtp,
      data: SendOtpRequestDto(email: email, purpose: purpose).toJson(),
    );
  }

  Future<bool> verifyOtp(String email, String code, String purpose) async {
    final res = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: VerifyOtpRequestDto(email: email, code: code, purpose: purpose).toJson(),
    );
    return (res.data as Map<String, dynamic>)['verified'] == true;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiEndpoints.forgotPassword,
      data: ForgotPasswordRequestDto(email: email).toJson(),
    );
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: ResetPasswordRequestDto(email: email, code: code, newPassword: newPassword).toJson(),
    );
  }
}