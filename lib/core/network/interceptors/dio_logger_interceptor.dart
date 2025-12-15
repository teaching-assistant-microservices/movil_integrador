// lib/core/network/interceptors/dio_logger_interceptor.dart
import 'package:dio/dio.dart';
import 'package:integrador/core/utils/logger.dart';

/// Interceptor de Dio con logging completo para debugging
class DioLoggerInterceptor extends Interceptor {
  final String serviceName;

  DioLoggerInterceptor({this.serviceName = 'API'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final stopwatch = Stopwatch()..start();

    // Guardar el stopwatch en extra para medición de tiempo
    options.extra['_request_start_time'] = stopwatch;

    // Log del request
    AppLogger.apiRequest(
      method: options.method,
      url: '${options.baseUrl}${options.path}',
      headers: options.headers,
      body: options.data,
      queryParams: options.queryParameters.isNotEmpty
          ? options.queryParameters
          : null,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Obtener tiempo de respuesta
    final stopwatch =
        response.requestOptions.extra['_request_start_time'] as Stopwatch?;
    stopwatch?.stop();

    // Log del response
    AppLogger.apiResponse(
      method: response.requestOptions.method,
      url: '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      duration: stopwatch?.elapsed,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Obtener tiempo hasta el error
    final stopwatch =
        err.requestOptions.extra['_request_start_time'] as Stopwatch?;
    stopwatch?.stop();

    // Log del error
    AppLogger.apiError(
      method: err.requestOptions.method,
      url: '${err.requestOptions.baseUrl}${err.requestOptions.path}',
      statusCode: err.response?.statusCode,
      errorMessage: _getErrorMessage(err),
      errorData: err.response?.data,
      duration: stopwatch?.elapsed,
    );

    handler.next(err);
  }

  /// Obtiene mensaje de error descriptivo
  String _getErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - El servidor no respondió a tiempo';
      case DioExceptionType.sendTimeout:
        return 'Send timeout - No se pudo enviar la petición';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - No se recibió respuesta del servidor';
      case DioExceptionType.badCertificate:
        return 'Bad certificate - Certificado SSL inválido';
      case DioExceptionType.badResponse:
        return 'Bad response - Error del servidor (${err.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Request cancelled - La petición fue cancelada';
      case DioExceptionType.connectionError:
        return 'Connection error - No se pudo conectar con el servidor';
      case DioExceptionType.unknown:
        return 'Unknown error - ${err.message ?? "Error desconocido"}';
    }
  }
}
