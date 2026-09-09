class AuthResponseDto {
  final String token;
  final String refreshToken;
  final String userId;
  final String role;

  const AuthResponseDto({
    required this.token,
    required this.refreshToken,
    required this.userId,
    this.role = 'customer',
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => AuthResponseDto(
        token: json['token']?.toString() ?? '',
        refreshToken: json['refreshToken']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        role: json['role']?.toString() ?? 'customer',
      );
}