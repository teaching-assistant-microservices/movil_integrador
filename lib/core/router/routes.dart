class AppRoutes {
  // ============================================
  // ROUTE NAMES (Nombres para uso interno)
  // ============================================

  // Auth Routes
  static const String login = 'login';
  static const String register = 'register';

  // Main Navigation Routes (Bottom Navigation Bar)
  static const String home = 'home';
  static const String assistant = 'assistant';
  static const String explore = 'explore';
  static const String analysis = 'analysis';
  static const String profile = 'profile';

  // Document Routes
  static const String uploadDocument = 'uploadDocument';
  static const String documentDetail = 'documentDetail';

  // Grouping Routes
  static const String groupingDetail = 'groupingDetail';
  static const String recommendations = 'recommendations';

  // Report Routes
  static const String reportPreview = 'reportPreview';
  static const String generateReport = 'generateReport';

  // Settings Routes
  static const String settings = 'settings';
  static const String preferences = 'preferences';
  static const String help = 'help';

  // ============================================
  // PATHS - RUTAS ABSOLUTAS (URLs)
  // ============================================

  static const String loginPath = '/login';
  static const String registerPath = '/register';

  static const String homePath = '/home';
  static const String assistantPath = '/assistant';
  static const String explorePath = '/explore';
  static const String analysisPath = '/analysis';
  static const String profilePath = '/profile';

  // 🔥 CORRECCIÓN APLICADA AQUÍ:
  // Cambiado de '/upload-document' a '/home/upload' para coincidir con el router.
  static const String uploadDocumentPath = '/home/upload';

  static const String documentDetailPath = '/documents/:documentId';

  static const String groupingDetailPath = '/groupings/:groupingId';
  static const String recommendationsPath =
      '/groupings/:groupingId/recommendations';

  static const String reportPreviewPath = '/reports/:reportId/preview';
  static const String generateReportPath = '/reports/generate';

  static const String settingsPath = '/settings';
  static const String preferencesPath = '/settings/preferences';
  static const String helpPath = '/settings/help';

  // ============================================
  // HELPER METHODS
  // ============================================
  static String getDocumentDetailPath(String documentId) =>
      '/documents/$documentId';
  static String getGroupingDetailPath(String groupingId) =>
      '/groupings/$groupingId';
  static String getRecommendationsPath(String groupingId) =>
      '/groupings/$groupingId/recommendations';
  static String getReportPreviewPath(String reportId) =>
      '/reports/$reportId/preview';
}
