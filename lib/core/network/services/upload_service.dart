import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:integrador/core/network/models/upload_file.dart';

class UploadService {
  final Dio _dio;

  static String getBaseUrl() {
    String baseUrl;

    if (kIsWeb) {
      baseUrl = 'http://localhost:8000';
    } else {
      try {
        if (Platform.isAndroid) {
          baseUrl = 'http://10.0.2.2:8000';
        } else if (Platform.isIOS) {
          baseUrl = 'http://localhost:8000';
        } else {
          baseUrl = 'http://192.168.1.100:8000';
        }
      } catch (e) {
        baseUrl = 'http://localhost:8000';
      }
    }

    return baseUrl;
  }

  UploadService([Dio? dio])
      : _dio = dio ?? _createDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  static Dio _createDio() {
    final baseUrl = getBaseUrl();

    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        validateStatus: (status) => status != null && status < 500,
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Response> uploadDocument({
    required UploadFile file,
    required String userId,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      late MultipartFile multipartFile;

      if (!file.isWeb && file.file != null) {
        multipartFile = await MultipartFile.fromFile(
          file.file!.path,
          filename: file.name,
        );
      } else if (file.bytes != null) {
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else {
        throw Exception('Archivo no válido: debe tener File o bytes');
      }

      final formData = FormData.fromMap({'file': multipartFile});

      final response = await _dio.post(
        '/documents/upload',
        data: formData,
        queryParameters: {'user_id': userId},
        onSendProgress: (sent, total) {
          if (onSendProgress != null) onSendProgress(sent, total);
        },
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Error del servidor (${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    } catch (e) {
      throw Exception('Error inesperado al subir archivo: $e');
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Timeout: el servidor no respondió a tiempo';
      case DioExceptionType.sendTimeout:
        return 'Timeout: no se pudo enviar el archivo';
      case DioExceptionType.receiveTimeout:
        return 'Timeout: no se recibió respuesta del servidor';
      case DioExceptionType.connectionError:
        return 'Error de conexión con ${_dio.options.baseUrl}';
      case DioExceptionType.badResponse:
        return 'Error del servidor (${e.response?.statusCode}): ${e.response?.data}';
      default:
        return 'Error desconocido: ${e.message}';
    }
  }
}