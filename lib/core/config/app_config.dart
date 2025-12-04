// lib/core/config/app_config.dart
class AppConfig {
  // ============================================
  // FEATURE FLAGS
  // ============================================
  static const bool useMockData =
      false; // ⚠️ Cambiar a false cuando ambos backends estén listos
  static const bool enableDebugLogs = false;

  // ============================================
  // API CONFIGURATION - DUAL BACKEND
  // ============================================

  // API Gateway (NestJS) - Puerto 3000
  // Maneja: Autenticación, Usuarios, Files
  static const String apiGatewayBaseUrl = useMockData
      ? 'http://localhost:3000'
      : 'https://api-gateway.production.com';

  // Core IA (Python/FastAPI) - Puerto 8000
  // Maneja: Chat, Ingestion, Classification, Analysis
  static const String coreAIBaseUrl = useMockData
      ? 'http://localhost:8000'
      : 'https://core-ia.production.com';

  // ============================================
  // ENDPOINTS - API GATEWAY (Puerto 3000)
  // ============================================
  static String get authLoginUrl => '$apiGatewayBaseUrl/auth/login';
  static String get authRegisterUrl => '$apiGatewayBaseUrl/auth/register';
  static String get authRefreshUrl => '$apiGatewayBaseUrl/auth/refresh';
  static String get authLogoutUrl => '$apiGatewayBaseUrl/auth/logout';
  static String get authValidateUrl => '$apiGatewayBaseUrl/auth/validate';

  static String get usersBaseUrl => '$apiGatewayBaseUrl/users';
  static String userByIdUrl(String id) => '$usersBaseUrl/$id';

  static String get filesBaseUrl => '$apiGatewayBaseUrl/files';
  static String fileByIdUrl(String id) => '$filesBaseUrl/$id';

  static String get healthCheckUrl => '$apiGatewayBaseUrl/health';

  // ============================================
  // ENDPOINTS - CORE IA (Puerto 8000)
  // ============================================
  static String get chatStreamUrl => '$coreAIBaseUrl/chat/stream';
  static String chatHistoryUrl(String userId) =>
      '$coreAIBaseUrl/chat/history/$userId';
  static String chatConversationUrl(String convId) =>
      '$coreAIBaseUrl/chat/conversation/$convId';

  static String get documentsUploadUrl => '$coreAIBaseUrl/documents/upload';
  static String get documentsListUrl => '$coreAIBaseUrl/documents';

  static String get analysisUrl => '$coreAIBaseUrl/analysis/clusters';

  // ============================================
  // MOCK CONFIGURATION
  // ============================================
  static const Duration mockDelay = Duration(milliseconds: 800);
  static const double mockErrorRate = 0.1; // 10% de errores simulados

  // ============================================
  // USER CONFIGURATION
  // ============================================
  static const String testUserId = 'test_user_123';
  static const String testEmail = 'demo@asistente.com';
  static const String testPassword = 'password123';

  // ============================================
  // TOKEN STORAGE KEYS
  // ============================================
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String expiresAtKey = 'expires_at';

  // ============================================
  // API CONFIGURATION
  // ============================================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Rate Limiting (API Gateway tiene límite de 10 req/min)
  static const int maxRequestsPerMinute = 10;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Retorna la URL correcta según si es mock o producción
  static String getApiUrl(ApiType type) {
    switch (type) {
      case ApiType.gateway:
        return apiGatewayBaseUrl;
      case ApiType.coreIA:
        return coreAIBaseUrl;
    }
  }

  /// Verifica si el modo mock está activo
  static bool get isMockMode => useMockData;

  /// Logs de debug (solo si está habilitado)
  static void debugLog(String message) {
    if (enableDebugLogs) {
      print('[AppConfig] $message');
    }
  }
}

enum ApiType {
  gateway, // API Gateway (Puerto 3000)
  coreIA, // Core IA (Puerto 8000)
}
