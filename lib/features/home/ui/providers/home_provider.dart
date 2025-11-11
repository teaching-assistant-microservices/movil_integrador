import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:integrador/core/network/models/upload_file.dart';
import 'package:integrador/core/network/services/upload_service.dart';
import 'package:integrador/features/home/data/repositories/home_repository_impl.dart';
import 'package:integrador/features/home/domain/entities/upload_result_entity.dart';
import 'package:integrador/features/home/domain/repositories/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository;

  HomeProvider({UploadService? uploadService})
      : _repository = HomeRepositoryImpl(
          uploadService ?? UploadService(), 
        );

  bool _isLoading = false;
  String? _errorMessage;
  UploadResultEntity? _lastUploadResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UploadResultEntity? get lastUploadResult => _lastUploadResult;

  Future<void> uploadFile(
    String filePath, {
    Uint8List? bytes,
    String? name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastUploadResult = null;
    notifyListeners();

    const userId = 'test_user_123'; 

    try {
      final uploadFile = kIsWeb
          ? UploadFile(
              name: name ?? 'documento.pdf',
              bytes: bytes!,
            )
          : UploadFile(
              name: name ?? filePath.split('/').last,
              file: File(filePath),
            );

      final result = await _repository.uploadDocument(
        file: uploadFile,
        userId: userId,
        onProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
        },
      );

      _lastUploadResult = result;
    } catch (e) {
      _errorMessage = 'No se pudo subir el archivo: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _errorMessage = 'Error al refrescar datos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}