// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Contrato del data source remoto
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String academicLevel,
  });

  Future<void> logout(String refreshToken);

  Future<UserModel> validateToken(String token);

  Future<UserModel> updateProfile({
    required String userId,
    required String token,
    String? name,
    String? academicLevel,
    String? password,
  });
}

/// Implementación del data source remoto con Dio
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error en login',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Credenciales inválidas');
      } else if (e.response?.statusCode == 429) {
        throw ServerException(
          message: 'Demasiados intentos. Intenta más tarde',
        );
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Error de conexión',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String academicLevel,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'academicLevel': academicLevel,
        },
      );

      if (response.statusCode == 201) {
        // Después de registro exitoso, hacer auto-login
        return await login(email: email, password: password);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al crear cuenta',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Datos inválidos';
        if (errorMsg.toString().contains('email')) {
          throw ServerException(message: 'Este email ya está registrado');
        }
        throw ServerException(message: errorMsg);
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Error al crear cuenta',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        '$baseUrl/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      // Ignoramos errores de logout en backend
      print('Error en logout (ignorado): ${e.message}');
    }
  }

  @override
  Future<UserModel> validateToken(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/auth/validate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw UnauthorizedException(message: 'Token inválido');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al validar token',
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    required String token,
    String? name,
    String? academicLevel,
    String? password,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (academicLevel != null) updateData['academicLevel'] = academicLevel;
      if (password != null) updateData['password'] = password;

      final response = await dio.put(
        '$baseUrl/users/$userId',
        data: updateData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Error al actualizar perfil');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al actualizar perfil',
      );
    }
  }
}

/// NOTA: Necesitas crear core/errors/exceptions.dart
/// para ServerException, UnauthorizedException, etc.
