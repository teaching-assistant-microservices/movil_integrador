// lib/core/mocks/files_mock_data.dart
class FilesMockData {
  static List<Map<String, dynamic>> mockFiles = [
    {
      'id': 'file_001',
      'filename': 'Guia_Matematicas.pdf',
      's3Key': 'uploads/test_user_123/matematicas_001.pdf',
      'userId': 'test_user_123',
      'status': 'COMPLETED',
      'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'size': 2458000, // bytes
    },
    {
      'id': 'file_002',
      'filename': 'Evaluacion_Formativa.pdf',
      's3Key': 'uploads/test_user_123/evaluacion_002.pdf',
      'userId': 'test_user_123',
      'status': 'COMPLETED',
      'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'size': 1850000,
    },
    {
      'id': 'file_003',
      'filename': 'Metodologia_Activa.pdf',
      's3Key': 'uploads/test_user_123/metodologia_003.pdf',
      'userId': 'test_user_123',
      'status': 'PROCESSING',
      'createdAt': DateTime.now()
          .subtract(Duration(hours: 2))
          .toIso8601String(),
      'size': 3200000,
    },
  ];

  static List<Map<String, dynamic>> getFilesByUserId(String userId) {
    return mockFiles.where((file) => file['userId'] == userId).toList();
  }

  static Map<String, dynamic>? getFileById(String id) {
    try {
      return mockFiles.firstWhere((file) => file['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> uploadFile({
    required String filename,
    required String userId,
    required int size,
  }) {
    final newFile = {
      'id': 'file_${DateTime.now().millisecondsSinceEpoch}',
      'filename': filename,
      's3Key': 'uploads/$userId/${filename.replaceAll(' ', '_')}',
      'userId': userId,
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
      'size': size,
    };

    mockFiles.add(newFile);

    // Simular procesamiento asíncrono
    Future.delayed(Duration(seconds: 3), () {
      final index = mockFiles.indexWhere((f) => f['id'] == newFile['id']);
      if (index != -1) {
        mockFiles[index]['status'] = 'COMPLETED';
      }
    });

    return newFile;
  }

  static bool deleteFile(String id) {
    final index = mockFiles.indexWhere((file) => file['id'] == id);
    if (index == -1) return false;

    mockFiles.removeAt(index);
    return true;
  }
}
