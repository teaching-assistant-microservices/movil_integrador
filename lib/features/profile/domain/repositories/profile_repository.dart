// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

/// Contrato del repositorio de perfiles (Domain Layer)
abstract class ProfileRepository {
  /// Obtener perfil completo del usuario actual
  Future<Either<Failure, UserProfile>> getProfile();

  /// Actualizar información del perfil
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    String? academicLevel,
    String? bio,
  });

  /// Cambiar contraseña
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Actualizar preferencias del usuario
  Future<Either<Failure, UserProfile>> updatePreferences(
    Map<String, dynamic> preferences,
  );

  /// Obtener perfil del cache
  Future<Either<Failure, UserProfile?>> getCachedProfile();

  /// Eliminar cuenta
  Future<Either<Failure, void>> deleteAccount();
}
