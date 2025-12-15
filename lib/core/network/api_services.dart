import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  Dio get dio => _dio;

  late final Dio _dio;
  String? _token;

  ApiService._internal() {
    final options = BaseOptions(
      baseUrl: 'http://142.44.162.37:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    // Interceptores
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  // ==========================================================
  // Actualiza token
  // ==========================================================
  void setToken(String token) => _token = token;

  // ==========================================================
  // MÉTODOS RAW (para usar desde tus providers)
  // ==========================================================

  Future<Response> rawGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> rawPost(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> rawPut(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> rawDelete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // GET genérico (DTO)
  // ==========================================================
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.data == null) throw Exception('Respuesta vacía de la API');
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // GET genérico lista
  // ==========================================================
  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.data == null) throw Exception('Respuesta vacía de la API');

      final dataList = response.data as List<dynamic>;
      return dataList.map((json) => fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // POST genérico
  // ==========================================================
  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      if (response.data == null) throw Exception('Respuesta vacía de la API');
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // POST lista
  // ==========================================================
  Future<List<T>> postList<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      if (response.data == null) throw Exception('Respuesta vacía de la API');

      final list = response.data as List<dynamic>;
      return list.map((json) => fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // PUT genérico
  // ==========================================================
  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      if (response.data == null) throw Exception('Respuesta vacía de la API');
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // DELETE genérico
  // ==========================================================
  Future<T> delete<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      if (response.data == null) throw Exception('Respuesta vacía de la API');
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================
  // STREAM (SSE)
  // ==========================================================
  Stream<T> getStream<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async* {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (var line in stream) {
      if (line.trim().isNotEmpty) {
        yield fromJson(jsonDecode(line));
      }
    }
  }

  // ==========================================================
  // Manejo de errores
  // ==========================================================
  Exception _handleError(DioException error) {
    if (error.response != null) {
      return Exception(
        error.response?.data['message'] ??
            'Error ${error.response?.statusCode}',
      );
    }
    return Exception('Conexión fallida: ${error.message}');
  }
}
