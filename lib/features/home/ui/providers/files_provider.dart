// ========================================
// PROVIDER 2: FilesProvider
// lib/features/home/ui/providers/files_provider.dart
// ========================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:integrador/core/config/app_config.dart';
import 'package:integrador/core/network/api_services.dart';
import 'package:integrador/core/utils/logger.dart';

class FilesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _files = [];
  List<dynamic> get files => _files;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Cargar lista de archivos
  Future<void> loadFiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('Cargando archivos', tag: 'FilesProvider');

      // 🔥 USAR rawGet AQUÍ
      final response = await _apiService.rawGet(AppConfig.filesBaseUrl);

      if (response.statusCode == 200) {
        _files = (response.data as List)
          ..sort((a, b) {
            final dateA =
                DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
            final dateB =
                DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

        AppLogger.success(
          '${_files.length} archivos cargados',
          tag: 'FilesProvider',
        );
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al cargar archivos';
      AppLogger.error(
        'Error al cargar archivos',
        tag: 'FilesProvider',
        error: e,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener archivo por ID
  Future<Map<String, dynamic>> getFileById(String fileId) async {
    try {
      AppLogger.info('Obteniendo archivo: $fileId', tag: 'FilesProvider');

      // 🔥 USAR rawGet AQUÍ
      final response = await _apiService.rawGet(AppConfig.fileByIdUrl(fileId));

      if (response.statusCode == 200) {
        AppLogger.success('Archivo obtenido: $fileId', tag: 'FilesProvider');
        return response.data;
      } else {
        throw Exception('Archivo no encontrado');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error al obtener archivo',
        tag: 'FilesProvider',
        error: e,
      );

      if (e.response?.statusCode == 404) {
        throw Exception('Archivo no encontrado');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Error al obtener archivo',
      );
    }
  }

  /// Eliminar archivo
  Future<void> deleteFile(String fileId) async {
    try {
      AppLogger.info('Eliminando archivo: $fileId', tag: 'FilesProvider');

      // 🔥 USAR rawDelete AQUÍ
      final response = await _apiService.rawDelete(
        AppConfig.fileByIdUrl(fileId),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        _files.removeWhere((file) => file['id'] == fileId);
        AppLogger.success('Archivo eliminado: $fileId', tag: 'FilesProvider');
        notifyListeners();
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error al eliminar archivo',
        tag: 'FilesProvider',
        error: e,
      );
      throw Exception(
        e.response?.data['message'] ?? 'Error al eliminar archivo',
      );
    }
  }
}
