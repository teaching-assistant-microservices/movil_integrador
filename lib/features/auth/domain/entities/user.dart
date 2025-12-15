// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

/// Entidad de Usuario (Domain Layer)
/// Es inmutable y representa la lógica de negocio pura
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String academicLevel;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.academicLevel,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, name, email, academicLevel, createdAt];
}

/// Respuesta de autenticación
class AuthResponse extends Equatable {
  final User user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [user, accessToken, refreshToken];
}
