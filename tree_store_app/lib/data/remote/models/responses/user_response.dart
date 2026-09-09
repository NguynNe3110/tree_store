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
        fullName: json['fullName']?.toString() ?? '',
        email: json['email'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        role: json['role']?.toString() ?? 'customer',
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );
}