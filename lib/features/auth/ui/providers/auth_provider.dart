// lib/features/auth/ui/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:integrador/core/config/app_config.dart';
import 'package:integrador/features/auth/data/datasources/token_storage.dart';
import 'package:integrador/features/auth/data/models/auth_response_dto.dart';
import 'package:integrador/features/auth/data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _repository = AuthRepositoryImpl();

  // Estado
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  UserDto? _currentUser;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserDto? get currentUser => _currentUser;
  String get userId => _currentUser?.id ?? 'unknown';

  /// Inicializar: Verificar si hay sesión activa
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _repository.isAuthenticated();

      if (_isAuthenticated) {
        final userData = await TokenStorage.getUserData();
        if (userData != null) {
          _currentUser = UserDto.fromJson(userData);
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Error al inicializar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(email, password) as AuthResponseDto;

      _isAuthenticated = true;
      _currentUser = response.user;
      _errorMessage = null;

      return true;
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register
  Future<bool> register({
    required String email,
    required String name,
    required String password,
    String? academicLevel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.register(
        email: email,
        name: name,
        password: password,
        academicLevel: academicLevel,
      );

      _isAuthenticated = true;
      _currentUser = response.user;
      _errorMessage = null;

      return true;
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
    } catch (e) {
      AppConfig.debugLog('Error en logout: $e');
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
