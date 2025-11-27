// lib/core/mocks/documents_mock_data.dart
class DocumentsMockData {
  static List<Map<String, dynamic>> mockDocuments = [
    {
      'id': 'doc_001',
      'title': 'Guía Didáctica de Matemáticas - Primaria',
      'filename': 'Guia_Matematicas_Primaria.pdf',
      'status': 'COMPLETED',
      'uploadedAt': DateTime.now()
          .subtract(Duration(days: 10))
          .toIso8601String(),
      'userId': 'test_user_123',
      'primaryCategory': 'Matemáticas',
      'keywords': ['multiplicación', 'división', 'fracciones'],
      'pageCount': 45,
      'fileSize': 2.3, // MB
    },
    {
      'id': 'doc_002',
      'title': 'Técnicas de Evaluación Formativa',
      'filename': 'Evaluacion_Formativa.pdf',
      'status': 'COMPLETED',
      'uploadedAt': DateTime.now()
          .subtract(Duration(days: 5))
          .toIso8601String(),
      'userId': 'test_user_123',
      'primaryCategory': 'Pedagogía',
      'keywords': ['evaluación', 'rúbricas', 'feedback'],
      'pageCount': 28,
      'fileSize': 1.8,
    },
    {
      'id': 'doc_003',
      'title': 'Estrategias de Enseñanza Activa',
      'filename': 'Ensenanza_Activa.pdf',
      'status': 'PROCESSING',
      'uploadedAt': DateTime.now()
          .subtract(Duration(hours: 2))
          .toIso8601String(),
      'userId': 'test_user_123',
      'primaryCategory': 'Metodología',
      'keywords': ['aprendizaje', 'participación', 'dinámicas'],
      'pageCount': null,
      'fileSize': 3.5,
    },
  ];

  static Map<String, dynamic> mockDocumentDetail(String docId) {
    final doc = mockDocuments.firstWhere(
      (d) => d['id'] == docId,
      orElse: () => mockDocuments.first,
    );

    return {
      ...doc,
      'summary':
          'Este documento presenta estrategias pedagógicas actualizadas '
          'para la enseñanza efectiva en el aula moderna.',
      'extractedTopics': ['Estrategias', 'Metodología', 'Evaluación'],
      'relatedDocuments': mockDocuments
          .where((d) => d['id'] != docId)
          .take(2)
          .toList(),
    };
  }
}
