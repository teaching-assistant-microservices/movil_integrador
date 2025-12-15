// lib/core/config/app_config.dart
// ✅ CONFIGURACIÓN CORREGIDA PARA PRODUCCIÓN

class AppConfig {
  // ============================================
  // FEATURE FLAGS
  // ============================================
  static const bool useMockData = false; // ⚠️ SIEMPRE false en producción
  static const bool enableDebugLogs = true;

  // ============================================
  // API CONFIGURATION - DUAL BACKEND
  // ============================================

  // 🔵 API Gateway (NestJS) - Puerto 3000
  // Maneja: Autenticación, Usuarios, Files (storage MinIO)
  static const String apiGatewayBaseUrl = 'http://142.44.162.37:3000';

  // 🟢 Core IA (Python/FastAPI) - Puerto 8000
  // Maneja: Chat, Documents (procesamiento), Classification, Generation, Stats
  // ⚠️ ACTUALIZADO: Cambiado de localhost a IP real
  static const String coreAIBaseUrl = 'http://127.0.0.1:8000';

  // ============================================
  // ENDPOINTS - API GATEWAY (Puerto 3000)
  // ============================================

  // Auth
  static String get authLoginUrl => '$apiGatewayBaseUrl/auth/login';
  static String get authRegisterUrl => '$apiGatewayBaseUrl/users';
  static String get authRefreshUrl => '$apiGatewayBaseUrl/auth/refresh';
  static String get authLogoutUrl => '$apiGatewayBaseUrl/auth/logout';
  static String get authValidateUrl => '$apiGatewayBaseUrl/auth/validate';

  // Users
  static String get usersBaseUrl => '$apiGatewayBaseUrl/users';
  static String userByIdUrl(String id) => '$usersBaseUrl/$id';

  // Files (Storage en MinIO)
  static String get filesBaseUrl => '$apiGatewayBaseUrl/files';
  static String fileByIdUrl(String id) => '$filesBaseUrl/$id';

  // Health
  static String get healthCheckUrl => '$apiGatewayBaseUrl/health';

  // ============================================
  // ENDPOINTS - CORE IA (Puerto 8000)
  // ============================================

  // 💬 Chat (sessions-based)
  static String get chatSessionsUrl => '$coreAIBaseUrl/api/v1/chat/sessions';
  static String chatSessionByIdUrl(String sessionId) =>
      '$chatSessionsUrl/$sessionId';
  static String chatQueryUrl(String sessionId) =>
      '$chatSessionsUrl/$sessionId/query';
  static String chatHistoryUrl(String sessionId) =>
      '$chatSessionsUrl/$sessionId/history';

  // 📄 Documents (procesamiento con IA)
  static String get documentsUploadUrl =>
      '$coreAIBaseUrl/api/v1/documents/upload';
  static String get documentsListUrl => '$coreAIBaseUrl/api/v1/documents';
  static String documentByIdUrl(String id) =>
      '$coreAIBaseUrl/api/v1/documents/$id';
  static String documentVerifyUrl(String id) =>
      '$coreAIBaseUrl/api/v1/documents/$id/verify';
  static String documentClassifyUrl(String id) =>
      '$coreAIBaseUrl/api/v1/documents/$id/classify';

  // 🏷️ Classification
  static String get classificationClassifyUrl =>
      '$coreAIBaseUrl/api/v1/classification/classify';
  static String get classificationCategoriesUrl =>
      '$coreAIBaseUrl/api/v1/classification/categories';

  // ✨ Generation
  static String get generationStudyGuideUrl =>
      '$coreAIBaseUrl/api/v1/generation/study-guide';
  static String get generationLessonPlanUrl =>
      '$coreAIBaseUrl/api/v1/generation/lesson-plan';

  // 📊 Stats
  static String get statsOverviewUrl => '$coreAIBaseUrl/api/v1/stats/overview';
  static String get statsDocumentsUrl =>
      '$coreAIBaseUrl/api/v1/stats/documents';
  static String get statsMlUrl => '$coreAIBaseUrl/api/v1/stats/ml';

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

  // Rate Limiting (API Gateway: 10 req/min)
  static const int maxRequestsPerMinute = 10;

  // ============================================
  // MOCK CONFIGURATION (legacy)
  // ============================================
  static const Duration mockDelay = Duration(milliseconds: 800);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Retorna la URL correcta según tipo de API
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
