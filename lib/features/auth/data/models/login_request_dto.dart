// lib/features/auth/data/models/login_request_dto.dart
class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
