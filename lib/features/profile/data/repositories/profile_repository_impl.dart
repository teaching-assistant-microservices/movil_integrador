// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:integrador/features/profile/data/models/user_profile_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

/// Implementación del repositorio de perfiles
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  // Necesitamos acceso a las credenciales actuales
  // En una implementación real, esto vendría del AuthRepository
  String? _cachedUserId;
  String? _cachedToken;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Helper: Obtener userId y token del auth
  /// NOTA: En producción esto debería venir del AuthRepository
  Future<(String userId, String token)> _getAuthData() async {
    // TODO: Integrar con AuthRepository para obtener datos reales
    // Por ahora usamos valores cacheados o lanzamos error

    if (_cachedUserId == null || _cachedToken == null) {
      throw UnauthorizedException(message: 'Usuario no autenticado');
    }

    return (_cachedUserId!, _cachedToken!);
  }

  /// Setter público para inyectar auth data (temporal)
  void setAuthData(String userId, String token) {
    _cachedUserId = userId;
    _cachedToken = token;
  }

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final (userId, token) = await _getAuthData();

      final profileModel = await remoteDataSource.getProfile(userId, token);

      // Guardar en cache
      await localDataSource.cacheProfile(profileModel);

      return Right(profileModel.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Si falla la red, intentar obtener del cache
      try {
        final cachedProfile = await localDataSource.getCachedProfile();
        if (cachedProfile != null) {
          return Right(cachedProfile.toEntity());
        }
      } catch (_) {}

      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    String? academicLevel,
    String? bio,
  }) async {
    try {
      final (userId, token) = await _getAuthData();

      final updatedProfile = await remoteDataSource.updateProfile(
        userId: userId,
        token: token,
        name: name,
        academicLevel: academicLevel,
        bio: bio,
      );

      // Actualizar cache
      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final (userId, token) = await _getAuthData();

      await remoteDataSource.changePassword(
        userId: userId,
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      // Las preferencias se guardan localmente por ahora
      // En el futuro podrían sincronizarse con el backend

      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile == null) {
        return const Left(CacheFailure('No hay perfil en cache'));
      }

      // Crear nuevo perfil con preferencias actualizadas
      final updatedProfile = UserProfileModel(
        id: cachedProfile.id,
        name: cachedProfile.name,
        email: cachedProfile.email,
        academicLevel: cachedProfile.academicLevel,
        createdAt: cachedProfile.createdAt,
        bio: cachedProfile.bio,
        preferences: preferences,
        stats: cachedProfile.stats,
      );

      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getCachedProfile() async {
    try {
      final cachedProfile = await localDataSource.getCachedProfile();
      return Right(cachedProfile?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final (userId, token) = await _getAuthData();

      await remoteDataSource.deleteAccount(userId, token);

      // Limpiar cache
      await localDataSource.clearCache();

      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
