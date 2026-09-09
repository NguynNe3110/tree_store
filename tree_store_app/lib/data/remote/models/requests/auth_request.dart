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
        'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}

class SendOtpRequestDto {
  final String email;
  final String purpose;
  const SendOtpRequestDto({required this.email, required this.purpose});

  Map<String, dynamic> toJson() => {'email': email, 'purpose': purpose};
}

class VerifyOtpRequestDto {
  final String email;
  final String code;
  final String purpose;
  const VerifyOtpRequestDto({required this.email, required this.code, required this.purpose});

  Map<String, dynamic> toJson() => {'email': email, 'code': code, 'purpose': purpose};
}

class ForgotPasswordRequestDto {
  final String email;
  const ForgotPasswordRequestDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequestDto {
  final String email;
  final String code;
  final String newPassword;
  const ResetPasswordRequestDto({required this.email, required this.code, required this.newPassword});

  Map<String, dynamic> toJson() => {'email': email, 'code': code, 'newPassword': newPassword};
}