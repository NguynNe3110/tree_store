class UserResponseDto {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final String? createdAt;
  final String? updatedAt;

  const UserResponseDto({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.role = 'customer',
    this.createdAt,
    this.updatedAt,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) => UserResponseDto(
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        email: json['email'] as String?,
        phoneNumber: json['phone_number'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        role: json['role']?.toString() ?? 'customer',
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );
}