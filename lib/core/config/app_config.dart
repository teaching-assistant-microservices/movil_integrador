// lib/core/config/app_config.dart
class AppConfig {
  // Feature Flags
  static const bool useMockData =
      true; // ⚠️ Cambiar a false cuando backend esté listo
  static const bool enableDebugLogs = true;

  // API Configuration
  static const String apiBaseUrl = useMockData
      ? 'http://localhost:8000' // No se usará si useMockData = true
      : 'https://api.production.com';

  // Mock Configuration
  static const Duration mockDelay = Duration(milliseconds: 800);
  static const double mockErrorRate = 0.1; // 10% de errores simulados

  // User ID for testing
  static const String testUserId = 'test_user_123';
}
