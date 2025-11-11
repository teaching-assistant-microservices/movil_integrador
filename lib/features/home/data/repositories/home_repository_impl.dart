import 'package:integrador/core/network/models/upload_file.dart';
import 'package:integrador/core/network/services/upload_service.dart';
import 'package:integrador/features/home/domain/entities/upload_result_entity.dart';
import 'package:integrador/features/home/domain/repositories/home_repository.dart';
import 'package:dio/dio.dart';

class HomeRepositoryImpl implements HomeRepository {
  final UploadService _uploadService;
  HomeRepositoryImpl(this._uploadService);

  @override
  Future<UploadResultEntity> uploadDocument({
    required UploadFile file,
    required String userId,
    Function(int, int)? onProgress,
  }) async {
    try {
      final Response response = await _uploadService.uploadDocument(
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
