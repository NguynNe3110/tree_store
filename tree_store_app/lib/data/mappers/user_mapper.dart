import '../../domain/entities/user.dart';
import '../remote/models/responses/user_response.dart';

extension UserResponseMapper on UserResponseDto {
  User toEntity() => User(
        id: id,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        role: role,
        createdAt: _parseDate(createdAt),
        updatedAt: _parseDate(updatedAt),
      );
}

DateTime? _parseDate(String? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}