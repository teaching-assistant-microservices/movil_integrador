// lib/features/auth/data/datasources/auth_api_service.dart
import 'package:dio/dio.dart';
import 'package:integrador/core/config/app_config.dart';
import 'package:integrador/features/auth/data/models/auth_response_dto.dart';
import 'package:integrador/features/auth/data/models/login_request_dto.dart';
import 'package:integrador/features/auth/data/models/register_request_dto.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiGatewayBaseUrl,
          connectTimeout: AppConfig.connectionTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppConfig.debugLog('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          AppConfig.debugLog(
            'Error: ${error.response?.statusCode} ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// POST /auth/login
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      if (response.statusCode == 200) {
        return AuthResponseDto.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/register
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    try {
      final response = await _dio.post(
        '/users', // Según la documentación, el registro es POST /users
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        // Después de crear usuario, hacer login automático
        return await login(
          LoginRequestDto(email: request.email, password: request.password),
        );
      } else {
        throw Exception('Register failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Datos inválidos o email ya existe');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/refresh
  Future<AuthResponseDto> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthResponseDto.fromJson(response.data);
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Error al refrescar token: $e');
    }
  }

  /// POST /auth/logout
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      AppConfig.debugLog('Error en logout: $e');
    }
  }

  /// GET /auth/validate
  Future<bool> validateToken(String accessToken) async {
    try {
      final response = await _dio.get(
        '/auth/validate',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
