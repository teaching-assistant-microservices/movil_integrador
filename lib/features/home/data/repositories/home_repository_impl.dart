import 'package:integrador/core/mocks/mock_service.dart';
import 'package:integrador/core/network/models/upload_file.dart';
import 'package:integrador/core/network/services/upload_service.dart';
import 'package:integrador/features/home/domain/entities/upload_result_entity.dart';
import 'package:integrador/features/home/domain/repositories/home_repository.dart';
import 'package:dio/dio.dart';

class HomeRepositoryImpl implements HomeRepository {
  final UploadService? _uploadService;
  final bool useMockData;

  HomeRepositoryImpl(UploadService? uploadService, {this.useMockData = true})
    : _uploadService = useMockData ? null : uploadService;

  @override
  Future<UploadResultEntity> uploadDocument({
    required UploadFile file,
    required String userId,
    Function(int, int)? onProgress,
  }) async {
    if (useMockData) {
      // Simular progreso
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 100));
        onProgress?.call(i, 100);
      }

      return await MockService.simulateApiCall(
        dataGenerator: () => UploadResultEntity(
          success: true,
          message: 'Documento subido exitosamente (simulado)',
          documentId: 'doc_mock_${DateTime.now().millisecondsSinceEpoch}',
          filename: file.name,
        ),
      );
    }

    try {
      final Response response = await _uploadService!.uploadDocument(
        file: file,
        userId: userId,
        onSendProgress: onProgress,
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};

      return UploadResultEntity(
        success: data['success'] ?? false,
        message: data['message'] ?? 'Error desconocido',
        documentId: data['document_id'],
        filename: data['filename'],
      );
    } catch (e) {
      return UploadResultEntity(
        success: false,
        message: 'Error al subir documento: ${e.toString()}',
      );
    }
  }
}
