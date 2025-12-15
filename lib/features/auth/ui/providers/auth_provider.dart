// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/features/auth/domain/usecases/login_usecase.dart';
import '../../domain/entities/user.dart';

/// Estados posibles de la autenticación
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// ViewModel de Autenticación usando Provider (MVVM)
///
/// Responsabilidades:
/// - Gestionar estado de UI
/// - Coordinar use cases
/// - Exponer datos de forma reactiva
/// - NO contiene lógica de negocio (eso está en UseCases)
class AuthProvider extends ChangeNotifier {
  // Dependencies (Use Cases)
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ValidateTokenUseCase validateTokenUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.validateTokenUseCase,
    required this.getCachedUserUseCase,
  });

  // ========================================
  // STATE
  // ========================================

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get hasError => _status == AuthStatus.error;

  // ========================================
  // INITIALIZE
  // ========================================

  /// Inicializar - verifica sesión persistente
  Future<void> initialize() async {
    _setStatus(AuthStatus.loading);

    // 1. Intentar obtener usuario del cache
    final cachedResult = await getCachedUserUseCase(NoParams());

    await cachedResult.fold(
      (failure) async {
        // No hay usuario en cache
        _setStatus(AuthStatus.unauthenticated);
      },
      (cachedUser) async {
        if (cachedUser != null) {
          // 2. Validar token con el servidor
          final validateResult = await validateTokenUseCase(NoParams());

          validateResult.fold(
            (failure) {
              // Token inválido
              _user = null;
              _setStatus(AuthStatus.unauthenticated);
            },
            (validUser) {
              // Token válido
              _user = validUser;
              _setStatus(AuthStatus.authenticated);
            },
          );
        } else {
          _setStatus(AuthStatus.unauthenticated);
        }
      },
    );
  }

  // ========================================
  // LOGIN
  // ========================================

  Future<bool> login({required String email, required String password}) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AuthStatus.error);
        return false;
      },
      (authResponse) {
        _user = authResponse.user;
        _setStatus(AuthStatus.authenticated);
        return true;
      },
    );
  }

  // ========================================
  // REGISTER
  // ========================================

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String academicLevel,
  }) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    final result = await registerUseCase(
      RegisterParams(
        name: name,
        email: email,
        password: password,
        academicLevel: academicLevel,
      ),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AuthStatus.error);
        return false;
      },
      (authResponse) {
        _user = authResponse.user;
        _setStatus(AuthStatus.authenticated);
        return true;
      },
    );
  }

  // ========================================
  // LOGOUT
  // ========================================

  Future<void> logout() async {
    _setStatus(AuthStatus.loading);

    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) {
        // Incluso si falla, limpiamos el estado local
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      },
      (_) {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      },
    );
  }

  // ========================================
  // HELPERS
  // ========================================

  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _setStatus(
        _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    }
  }
}
