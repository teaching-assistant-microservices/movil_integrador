import 'package:dio/dio.dart';
import 'package:integrador/core/config/app_config.dart';
import 'package:integrador/core/config/token_storage.dart';
import 'package:integrador/core/network/models/upload_file.dart';

class UploadService {
  final Dio _dio;

  UploadService([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  AppConfig.apiGatewayBaseUrl, // Usar Gateway (Puerto 3000)
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            ),
          );

  Future<Response> uploadDocument({
    required UploadFile file,
    // El userId ya no es necesario aquí porque el backend lo saca del Token JWT
    Function(int, int)? onSendProgress,
  }) async {
    try {
      // 1. Obtener Token
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception('Usuario no autenticado');

      // 2. Preparar archivo
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
        throw Exception('Archivo inválido');
      }

      // 3. Crear FormData (Key debe ser 'file' según api-1.json)
      final formData = FormData.fromMap({'file': multipartFile});

      // 4. Enviar Petición a /files
      final response = await _dio.post(
        '/files',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Auth correcta
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );

      return response;
    } on DioException catch (e) {
      // Manejo de errores simplificado
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
