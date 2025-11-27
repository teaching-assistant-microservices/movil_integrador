// lib/core/mocks/analysis_mock_data.dart
class AnalysisMockData {
  static Map<String, dynamic> mockClusters() {
    return {
      'total_documents': 15,
      'clusters': [
        {
          'cluster_id': 0,
          'label': 'Matemáticas Primaria',
          'document_count': 6,
          'coherence_score': 0.87,
          'top_keywords': ['multiplicación', 'suma', 'resta', 'números'],
          'documents': ['doc_001', 'doc_004', 'doc_007'],
        },
        {
          'cluster_id': 1,
          'label': 'Evaluación y Retroalimentación',
          'document_count': 4,
          'coherence_score': 0.92,
          'top_keywords': ['evaluación', 'rúbrica', 'feedback', 'criterios'],
          'documents': ['doc_002', 'doc_009'],
        },
        {
          'cluster_id': 2,
          'label': 'Metodologías Activas',
          'document_count': 5,
          'coherence_score': 0.78,
          'top_keywords': ['participación', 'dinámicas', 'colaboración'],
          'documents': ['doc_003', 'doc_011'],
        },
      ],
      'silhouette_score': 0.76,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> mockMetrics() {
    return {
      'total_documents': 15,
      'processing_status': {'completed': 12, 'processing': 2, 'failed': 1},
      'categories_distribution': {
        'Matemáticas': 6,
        'Pedagogía': 4,
        'Metodología': 5,
      },
      'recent_activity': {'uploads_last_7_days': 3, 'queries_last_7_days': 24},
    };
  }
}
