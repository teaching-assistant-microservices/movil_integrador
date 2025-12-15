// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Contrato del repositorio de autenticación (Domain Layer)
/// Define QUÉ hacer, no CÓMO hacerlo
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Registro de nuevo usuario
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String academicLevel,
  });

  /// Cerrar sesión
  Future<Either<Failure, void>> logout();

  /// Validar token actual
  Future<Either<Failure, User>> validateToken();

  /// Actualizar perfil
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? academicLevel,
    String? password,
  });

  /// Obtener usuario actual del cache
  Future<Either<Failure, User?>> getCachedUser();
}
