// lib/features/profile/presentation/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_usecases.dart';

/// Estados posibles del perfil
enum ProfileStatus { initial, loading, success, error }

/// ViewModel de Perfil usando Provider (MVVM)
class ProfileProvider extends ChangeNotifier {
  // Dependencies (Use Cases)
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;
  final GetCachedProfileUseCase getCachedProfileUseCase;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.updatePreferencesUseCase,
    required this.getCachedProfileUseCase,
  });

  // ========================================
  // STATE
  // ========================================

  ProfileStatus _status = ProfileStatus.initial;
  ProfileStatus get status => _status;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ProfileStatus.loading;
  bool get hasError => _status == ProfileStatus.error;
  bool get hasProfile => _profile != null;

  // ========================================
  // INITIALIZE
  // ========================================

  Future<void> initialize() async {
    // Intentar obtener perfil del cache primero
    final cachedResult = await getCachedProfileUseCase(NoParams());

    cachedResult.fold(
      (_) {
        // No hay cache, cargar desde API
        loadProfile();
      },
      (cachedProfile) {
        if (cachedProfile != null) {
          _profile = cachedProfile;
          notifyListeners();

          // Refrescar en background
          loadProfile();
        } else {
          loadProfile();
        }
      },
    );
  }

  // ========================================
  // LOAD PROFILE
  // ========================================

  Future<void> loadProfile() async {
    _setStatus(ProfileStatus.loading);
    _errorMessage = null;

    AppLogger.info('Cargando perfil', tag: 'ProfileProvider');

    final result = await getProfileUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(ProfileStatus.error);
        AppLogger.error(
          'Error al cargar perfil',
          tag: 'ProfileProvider',
          error: failure,
        );
      },
      (profile) {
        _profile = profile;
        _setStatus(ProfileStatus.success);
        AppLogger.success(
          'Perfil cargado: ${profile.name}',
          tag: 'ProfileProvider',
        );
      },
    );
  }

  // ========================================
  // UPDATE PROFILE
  // ========================================

  Future<bool> updateProfile({
    String? name,
    String? academicLevel,
    String? bio,
  }) async {
    _setStatus(ProfileStatus.loading);
    _errorMessage = null;

    AppLogger.info('Actualizando perfil', tag: 'ProfileProvider');

    final result = await updateProfileUseCase(
      UpdateProfileParams(name: name, academicLevel: academicLevel, bio: bio),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(ProfileStatus.error);
        AppLogger.error(
          'Error al actualizar perfil',
          tag: 'ProfileProvider',
          error: failure,
        );
        return false;
      },
      (updatedProfile) {
        _profile = updatedProfile;
        _setStatus(ProfileStatus.success);
        AppLogger.success('Perfil actualizado', tag: 'ProfileProvider');
        return true;
      },
    );
  }

  // ========================================
  // CHANGE PASSWORD
  // ========================================

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;

    AppLogger.info('Cambiando contraseña', tag: 'ProfileProvider');

    final result = await changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppLogger.error(
          'Error al cambiar contraseña',
          tag: 'ProfileProvider',
          error: failure,
        );
        notifyListeners();
        return false;
      },
      (_) {
        AppLogger.success(
          'Contraseña cambiada exitosamente',
          tag: 'ProfileProvider',
        );
        return true;
      },
    );
  }

  // ========================================
  // UPDATE PREFERENCES
  // ========================================

  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    _errorMessage = null;

    AppLogger.info('Actualizando preferencias', tag: 'ProfileProvider');

    final result = await updatePreferencesUseCase(
      PreferencesParams(preferences),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppLogger.error(
          'Error al actualizar preferencias',
          tag: 'ProfileProvider',
          error: failure,
        );
        notifyListeners();
        return false;
      },
      (updatedProfile) {
        _profile = updatedProfile;
        AppLogger.success('Preferencias actualizadas', tag: 'ProfileProvider');
        notifyListeners();
        return true;
      },
    );
  }

  // ========================================
  // HELPERS
  // ========================================

  void _setStatus(ProfileStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    _status = ProfileStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
