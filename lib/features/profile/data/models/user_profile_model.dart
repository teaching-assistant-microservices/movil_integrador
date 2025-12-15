// lib/features/profile/data/models/user_profile_model.dart
import '../../domain/entities/user_profile.dart';

/// Modelo de Perfil de Usuario (Data Layer)
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.academicLevel,
    required super.createdAt,
    super.bio,
    super.preferences,
    super.stats,
  });

  /// Crear desde JSON (API response)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      academicLevel: json['academicLevel'] as String? ?? 'Universidad',
      createdAt: DateTime.parse(json['createdAt'] as String),
      bio: json['bio'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      stats: json['stats'] != null
          ? UserStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'academicLevel': academicLevel,
      'createdAt': createdAt.toIso8601String(),
      if (bio != null) 'bio': bio,
      if (preferences != null) 'preferences': preferences,
      if (stats != null) 'stats': (stats as UserStatsModel).toJson(),
    };
  }

  /// Convertir a entidad pura
  UserProfile toEntity() => this;

  /// Crear desde entidad
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      academicLevel: profile.academicLevel,
      createdAt: profile.createdAt,
      bio: profile.bio,
      preferences: profile.preferences,
      stats: profile.stats,
    );
  }
}

/// Modelo de estadísticas
class UserStatsModel extends UserStats {
  const UserStatsModel({
    super.totalDocuments,
    super.totalQueries,
    super.totalReports,
    super.lastActivity,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalDocuments: json['totalDocuments'] as int? ?? 0,
      totalQueries: json['totalQueries'] as int? ?? 0,
      totalReports: json['totalReports'] as int? ?? 0,
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDocuments': totalDocuments,
      'totalQueries': totalQueries,
      'totalReports': totalReports,
      if (lastActivity != null) 'lastActivity': lastActivity!.toIso8601String(),
    };
  }
}
