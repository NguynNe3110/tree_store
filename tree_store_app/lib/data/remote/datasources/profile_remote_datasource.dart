import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/responses/user_response.dart';

class ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSource(this._dio);

  Future<UserResponseDto> getProfile() async {
    final res = await _dio.get(ApiEndpoints.profile);
    return UserResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserResponseDto> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    final res = await _dio.put(ApiEndpoints.profile, data: body);
    return UserResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}