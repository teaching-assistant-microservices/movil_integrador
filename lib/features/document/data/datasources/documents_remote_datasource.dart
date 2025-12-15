import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/models/upload_file.dart';
import '../../../../core/network/services/upload_service.dart';
import '../models/document_model.dart';

abstract class DocumentsRemoteDataSource {
  Future<List<DocumentModel>> getDocuments();
  Future<DocumentModel> getDocumentById(String id);
  Future<DocumentModel> uploadDocument({
    required String filename,
    required List<int> bytes,
    Function(int sent, int total)? onProgress,
  });
  Future<void> deleteDocument(String id);
  Future<List<DocumentModel>> searchDocuments(String query);
}

class DocumentsRemoteDataSourceImpl implements DocumentsRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  DocumentsRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await dio.get('$baseUrl/files');

      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map((json) => DocumentModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Error al obtener documentos');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error de conexión',
      );
    }
  }

  @override
  Future<DocumentModel> getDocumentById(String id) async {
    try {
      final response = await dio.get('$baseUrl/files/$id');

      if (response.statusCode == 200) {
        return DocumentModel.fromJson(response.data);
      } else {
        throw NotFoundException(message: 'Documento no encontrado');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Documento no encontrado');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al obtener documento',
      );
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String filename,
    required List<int> bytes,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final uploadService = UploadService(dio);

      final uploadFile = UploadFile(
        name: filename,
        bytes: Uint8List.fromList(bytes),
      );

      final response = await uploadService.uploadDocument(
        file: uploadFile,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return DocumentModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Error al subir documento');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al subir documento',
      );
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      final response = await dio.delete('$baseUrl/files/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ServerException(message: 'Error al eliminar documento');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al eliminar documento',
      );
    }
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    try {
      final response = await dio.get(
        '$baseUrl/files',
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map((json) => DocumentModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Error en búsqueda');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error en búsqueda',
      );
    }
  }
}
