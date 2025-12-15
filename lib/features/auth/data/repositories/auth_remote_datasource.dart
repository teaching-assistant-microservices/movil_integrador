// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
/// Une el data source remoto y local
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Llamar al API
      final responseModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // 2. Guardar en cache
      await localDataSource.cacheUser(responseModel.user);
      await localDataSource.cacheTokens(
        responseModel.accessToken,
        responseModel.refreshToken,
      );

      // 3. Retornar entidad limpia
      return Right(
        AuthResponse(
          user: responseModel.user.toEntity(),
          accessToken: responseModel.accessToken,
          refreshToken: responseModel.refreshToken,
        ),
      );
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String academicLevel,
  }) async {
    try {
      // 1. Llamar al API
      final responseModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        academicLevel: academicLevel,
      );

      // 2. Guardar en cache
      await localDataSource.cacheUser(responseModel.user);
      await localDataSource.cacheTokens(
        responseModel.accessToken,
        responseModel.refreshToken,
      );

      // 3. Retornar entidad limpia
      return Right(
        AuthResponse(
          user: responseModel.user.toEntity(),
          accessToken: responseModel.accessToken,
          refreshToken: responseModel.refreshToken,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // 1. Obtener refresh token
      final refreshToken = await localDataSource.getRefreshToken();

      // 2. Llamar al API (opcional, puede fallar sin problema)
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken);
      }

      // 3. Limpiar cache local
      await localDataSource.clearCache();
      await localDataSource.clearTokens();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      // Incluso si falla, limpiamos el cache
      await localDataSource.clearCache();
      await localDataSource.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> validateToken() async {
    try {
      // 1. Obtener token del cache
      final token = await localDataSource.getAccessToken();

      if (token == null) {
        return const Left(UnauthorizedFailure('No hay token'));
      }

      // 2. Validar con el API
      final userModel = await remoteDataSource.validateToken(token);

      // 3. Actualizar cache
      await localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on UnauthorizedException catch (e) {
      // Token inválido - limpiar cache
      await localDataSource.clearCache();
      await localDataSource.clearTokens();
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? academicLevel,
    String? password,
  }) async {
    try {
      // 1. Obtener usuario y token actual
      final cachedUser = await localDataSource.getCachedUser();
      final token = await localDataSource.getAccessToken();

      if (cachedUser == null || token == null) {
        return const Left(UnauthorizedFailure('Usuario no autenticado'));
      }

      // 2. Actualizar en el API
      final updatedUser = await remoteDataSource.updateProfile(
        userId: cachedUser.id,
        token: token,
        name: name,
        academicLevel: academicLevel,
        password: password,
      );

      // 3. Actualizar cache
      await localDataSource.cacheUser(updatedUser);

      return Right(updatedUser.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
