// lib/core/mocks/health_mock_data.dart
class HealthMockData {
  static Map<String, dynamic> mockHealthCheck() {
    return {
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'services': {'auth': 'healthy', 'users': 'healthy', 'files': 'healthy'},
      'info': {
        'database': {'status': 'up'},
      },
      'details': {
        'database': {'status': 'up'},
      },
    };
  }

  static Map<String, dynamic> mockCoreIAHealth() {
    return {
      'status': 'healthy',
      'timestamp': DateTime.now().toIso8601String(),
      'services': {
        'ingestion': 'healthy',
        'verification': 'healthy',
        'classification': 'healthy',
        'chat': 'healthy',
        'enrichment': 'healthy',
        'database': 'healthy',
      },
      'metrics': {
        'uptime_seconds': 3600,
        'requests_per_minute': 150,
        'avg_response_time_ms': 245,
      },
    };
  }
}
