import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/responses/address_response.dart';
import '../models/responses/user_response.dart';

class ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSource(this._dio);

  Future<UserResponseDto> getProfile() async {
    final res = await _dio.get(ApiEndpoints.profile);
    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('Invalid profile response');
    return UserResponseDto.fromJson(data);
  }

  Future<UserResponseDto> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
    final res = await _dio.put(ApiEndpoints.profile, data: body);
    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('Invalid profile response');
    return UserResponseDto.fromJson(data);
  }

  Future<List<AddressResponseDto>> getAddresses() async {
    final res = await _dio.get(ApiEndpoints.addresses);
    final raw = (res.data as List?) ?? const [];
    return raw.whereType<Map<String, dynamic>>().map(AddressResponseDto.fromJson).toList();
  }

  Future<String> addAddress({
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
    final res = await _dio.post(
      ApiEndpoints.addresses,
      data: {
        if (label != null) 'label': label,
        'receiverName': receiverName,
        'phoneNumber': phoneNumber,
        'addressLine': addressLine,
        'city': city,
        'district': district,
        if (ward != null) 'ward': ward,
        if (postalCode != null) 'postalCode': postalCode,
        'isDefault': isDefault,
      },
    );
    return res.data['id']?.toString() ?? '';
  }
}