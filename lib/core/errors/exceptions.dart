// lib/core/errors/exceptions.dart

/// Excepción base
class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

/// Excepción del servidor
class ServerException extends AppException {
  ServerException({super.message = 'Error del servidor'});
}

/// Excepción de caché
class CacheException extends AppException {
  CacheException({super.message = 'Error de caché'});
}

/// Excepción de red
class NetworkException extends AppException {
  NetworkException({super.message = 'Sin conexión a internet'});
}

/// Excepción de autorización
class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'No autorizado'});
}

/// Excepción de validación
class ValidationException extends AppException {
  ValidationException({super.message = 'Datos inválidos'});
}

/// Excepción de recurso no encontrado
class NotFoundException extends AppException {
  NotFoundException({super.message = 'Recurso no encontrado'});
}
