// lib/features/profile/domain/entities/user_profile.dart
import 'package:equatable/equatable.dart';

/// Entidad de Perfil de Usuario (Domain Layer)
/// Representa el perfil completo del usuario
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String academicLevel;
  final DateTime createdAt;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final UserStats? stats;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.academicLevel,
    required this.createdAt,
    this.bio,
    this.preferences,
    this.stats,
  });

  // Helpers
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    academicLevel,
    createdAt,
    bio,
    preferences,
    stats,
  ];
}

/// Estadísticas del usuario
class UserStats extends Equatable {
  final int totalDocuments;
  final int totalQueries;
  final int totalReports;
  final DateTime? lastActivity;

  const UserStats({
    this.totalDocuments = 0,
    this.totalQueries = 0,
    this.totalReports = 0,
    this.lastActivity,
  });

  @override
  List<Object?> get props => [
    totalDocuments,
    totalQueries,
    totalReports,
    lastActivity,
  ];
}
