// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:integrador/core/mocks/auth_mock_data.dart';
import 'package:integrador/core/config/app_config.dart';
import 'package:integrador/features/auth/data/datasources/auth_api_service.dart';
import 'package:integrador/features/auth/data/datasources/token_storage.dart';
import 'package:integrador/features/auth/data/models/auth_response_dto.dart';
import 'package:integrador/features/auth/data/models/login_request_dto.dart';
import 'package:integrador/features/auth/data/models/register_request_dto.dart';

class AuthRepositoryImpl {
  final AuthApiService? _apiService;
  final bool useMockData;

  AuthRepositoryImpl({
    AuthApiService? apiService,
    this.useMockData = AppConfig.useMockData,
  }) : _apiService = useMockData ? null : (apiService ?? AuthApiService());

  Future<Object> login(String email, String password) async {
    if (useMockData) {
      await Future.delayed(AppConfig.mockDelay);
      return AuthMockData.mockLogin(email, password);
    }

    final request = LoginRequestDto(email: email, password: password);
    final response = await _apiService!.login(request);

    // Guardar tokens
    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresIn: response.expiresIn,
      userData: response.user.toJson(),
    );

    return response;
  }

  Future<AuthResponseDto> register({
    required String email,
    required String name,
    required String password,
    String? academicLevel,
  }) async {
    if (useMockData) {
      await Future.delayed(AppConfig.mockDelay);
      return AuthMockData.mockRegister(email, name, password);
    }

    final request = RegisterRequestDto(
      email: email,
      name: name,
      password: password,
      academicLevel: academicLevel,
    );

    final response = await _apiService!.register(request);

    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresIn: response.expiresIn,
      userData: response.user.toJson(),
    );

    return response;
  }

  Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (!useMockData && refreshToken != null) {
      await _apiService!.logout(refreshToken);
    }

    await TokenStorage.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null) return false;

    final isExpired = await TokenStorage.isTokenExpired();
    if (isExpired) {
      // Intentar refrescar token
      return await _refreshTokenIfNeeded();
    }

    return true;
  }

  Future<bool> _refreshTokenIfNeeded() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      if (useMockData) {
        return true;
      }

      final response = await _apiService!.refreshToken(refreshToken);

      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
        userData: response.user.toJson(),
      );

      return true;
    } catch (e) {
      await TokenStorage.clearTokens();
      return false;
    }
  }
}
