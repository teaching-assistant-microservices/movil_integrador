// lib/features/auth/data/models/auth_response_dto.dart
class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserDto user;

  AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserDto {
  final String id;
  final String email;
  final String name;

  UserDto({required this.id, required this.email, required this.name});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};
}
