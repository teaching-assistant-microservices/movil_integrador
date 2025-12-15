// lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

/// Modelo de Usuario (Data Layer)
/// Maneja serialización/deserialización JSON
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.academicLevel,
    required super.createdAt,
  });

  /// Crear desde JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      academicLevel: json['academicLevel'] as String? ?? 'Universidad',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convertir a JSON (para cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'academicLevel': academicLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convertir a entidad pura
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      academicLevel: academicLevel,
      createdAt: createdAt,
    );
  }

  /// Crear desde entidad
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      academicLevel: user.academicLevel,
      createdAt: user.createdAt,
    );
  }
}

/// Modelo de respuesta de autenticación
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
