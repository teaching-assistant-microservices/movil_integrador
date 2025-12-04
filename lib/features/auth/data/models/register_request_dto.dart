// lib/features/auth/data/models/register_request_dto.dart
class RegisterRequestDto {
  final String email;
  final String name;
  final String password;
  final String? academicLevel;

  RegisterRequestDto({
    required this.email,
    required this.name,
    required this.password,
    this.academicLevel,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'password': password,
    if (academicLevel != null) 'academicLevel': academicLevel,
  };
}
