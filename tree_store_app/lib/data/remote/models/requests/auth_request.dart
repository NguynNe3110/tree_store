class LoginRequestDto {
  final String email;
  final String password;
  const LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequestDto {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };
}