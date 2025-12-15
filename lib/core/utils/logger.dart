// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';

/// Sistema centralizado de logging para debugging
class AppLogger {
  // Colores ANSI para terminal (solo funcionan en debug)
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _bold = '\x1B[1m';

  // Flag para habilitar/deshabilitar logs
  static bool enableLogs = true;

  /// Log general de información
  static void info(String message, {String? tag}) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint(
      '$_blue$_bold[INFO]$_reset $timestamp $tagStr $_white$message$_reset',
    );
  }

  /// Log de éxito (operaciones exitosas)
  static void success(String message, {String? tag}) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint(
      '$_green$_bold[SUCCESS]$_reset $timestamp $tagStr $_white$message$_reset',
    );
  }

  /// Log de advertencia
  static void warning(String message, {String? tag}) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint(
      '$_yellow$_bold[WARNING]$_reset $timestamp $tagStr $_white$message$_reset',
    );
  }

  /// Log de error
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint(
      '$_red$_bold[ERROR]$_reset $timestamp $tagStr $_white$message$_reset',
    );
    if (error != null) {
      debugPrint('$_red  └─ Error: $error$_reset');
    }
    if (stackTrace != null) {
      debugPrint(
        '$_red  └─ StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}$_reset',
      );
    }
  }

  /// Log de debug (información técnica detallada)
  // ⬅️ CAMBIO: Parámetro data es opcional con valor por defecto
  static void debug(
    String message, {
    String? tag,
    Map<String, Object> data = const {},
  }) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint(
      '$_cyan[DEBUG]$_reset $timestamp $tagStr $_white$message$_reset',
    );

    // Mostrar datos si existen
    if (data.isNotEmpty) {
      data.forEach((key, value) {
        debugPrint('$_cyan  ├─ $key: $value$_reset');
      });
    }
  }

  // ========================================
  // LOGS ESPECÍFICOS PARA API
  // ========================================

  /// Log de request HTTP
  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint(
      '\n$_magenta$_bold╔════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_magenta$_bold║ API REQUEST$_reset $timestamp');
    debugPrint(
      '$_magenta$_bold╠════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_magenta║$_reset $_bold$method$_reset $url');

    if (queryParams != null && queryParams.isNotEmpty) {
      debugPrint('$_magenta║$_reset ${_cyan}Query Params:$_reset');
      queryParams.forEach((key, value) {
        debugPrint('$_magenta║$_reset   • $key: $value');
      });
    }

    if (headers != null && headers.isNotEmpty) {
      debugPrint('$_magenta║$_reset ${_cyan}Headers:$_reset');
      headers.forEach((key, value) {
        // No mostrar tokens completos por seguridad
        if (key.toLowerCase().contains('authorization')) {
          final token = value.toString();
          final masked = token.length > 20
              ? '${token.substring(0, 10)}...${token.substring(token.length - 10)}'
              : token;
          debugPrint('$_magenta║$_reset   • $key: $masked');
        } else {
          debugPrint('$_magenta║$_reset   • $key: $value');
        }
      });
    }

    if (body != null) {
      debugPrint('$_magenta║$_reset ${_cyan}Body:$_reset');
      if (body is Map || body is List) {
        final bodyStr = body.toString();
        if (bodyStr.length > 500) {
          debugPrint(
            '$_magenta║$_reset   ${bodyStr.substring(0, 500)}... (truncated)',
          );
        } else {
          debugPrint('$_magenta║$_reset   $bodyStr');
        }
      } else {
        debugPrint('$_magenta║$_reset   $body');
      }
    }

    debugPrint(
      '$_magenta$_bold╚════════════════════════════════════════════════════════════$_reset\n',
    );
  }

  /// Log de response HTTP exitoso
  static void apiResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic data,
    Duration? duration,
  }) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final durationStr = duration != null
        ? ' (${duration.inMilliseconds}ms)'
        : '';

    debugPrint(
      '\n$_green$_bold╔════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_green$_bold║ API RESPONSE$_reset $timestamp$durationStr');
    debugPrint(
      '$_green$_bold╠════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_green║$_reset $_bold$method$_reset $url');
    debugPrint(
      '$_green║$_reset ${_cyan}Status:$_reset $_green$statusCode OK$_reset',
    );

    if (data != null) {
      debugPrint('$_green║$_reset ${_cyan}Response Data:$_reset');
      final dataStr = data.toString();
      if (dataStr.length > 1000) {
        debugPrint(
          '$_green║$_reset   ${dataStr.substring(0, 1000)}... (truncated)',
        );
        debugPrint(
          '$_green║$_reset   $_yellow[Data size: ${dataStr.length} characters]$_reset',
        );
      } else {
        debugPrint('$_green║$_reset   $dataStr');
      }
    }

    debugPrint(
      '$_green$_bold╚════════════════════════════════════════════════════════════$_reset\n',
    );
  }

  /// Log de error HTTP
  static void apiError({
    required String method,
    required String url,
    int? statusCode,
    String? errorMessage,
    dynamic errorData,
    Duration? duration,
  }) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final durationStr = duration != null
        ? ' (${duration.inMilliseconds}ms)'
        : '';

    debugPrint(
      '\n$_red$_bold╔════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_red$_bold║ API ERROR$_reset $timestamp$durationStr');
    debugPrint(
      '$_red$_bold╠════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_red║$_reset $_bold$method$_reset $url');

    if (statusCode != null) {
      debugPrint(
        '$_red║$_reset ${_cyan}Status:$_reset $_red$statusCode ERROR$_reset',
      );
    }

    if (errorMessage != null) {
      debugPrint('$_red║$_reset ${_cyan}Error Message:$_reset');
      debugPrint('$_red║$_reset   $errorMessage');
    }

    if (errorData != null) {
      debugPrint('$_red║$_reset ${_cyan}Error Data:$_reset');
      debugPrint('$_red║$_reset   $errorData');
    }

    debugPrint(
      '$_red$_bold╚════════════════════════════════════════════════════════════$_reset\n',
    );
  }

  // ========================================
  // LOGS PARA STREAMING
  // ========================================

  /// Log de inicio de stream
  static void streamStart(String streamName, {Map<String, dynamic>? params}) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint(
      '\n$_cyan$_bold╔════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_cyan$_bold║ STREAM START$_reset $timestamp');
    debugPrint(
      '$_cyan$_bold╠════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_cyan║$_reset Stream: $_bold$streamName$_reset');

    if (params != null) {
      debugPrint('$_cyan║$_reset Parameters:');
      params.forEach((key, value) {
        debugPrint('$_cyan║$_reset   • $key: $value');
      });
    }

    debugPrint(
      '$_cyan$_bold╚════════════════════════════════════════════════════════════$_reset\n',
    );
  }

  /// Log de evento de stream
  static void streamEvent(String streamName, String eventType, dynamic data) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint(
      '$_cyan[STREAM EVENT]$_reset $timestamp [$streamName] Type: $_bold$eventType$_reset',
    );

    if (data != null) {
      final dataStr = data.toString();
      if (dataStr.length > 200) {
        debugPrint('  └─ Data: ${dataStr.substring(0, 200)}... (truncated)');
      } else {
        debugPrint('  └─ Data: $dataStr');
      }
    }
  }

  /// Log de error en stream
  static void streamError(String streamName, dynamic error) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint('$_red$_bold[STREAM ERROR]$_reset $timestamp [$streamName]');
    debugPrint('$_red  └─ Error: $error$_reset');
  }

  /// Log de finalización de stream
  static void streamDone(String streamName, {int? eventsReceived}) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint('\n$_green$_bold[STREAM DONE]$_reset $timestamp [$streamName]');
    if (eventsReceived != null) {
      debugPrint('$_green  └─ Total events received: $eventsReceived$_reset');
    }
  }

  // ========================================
  // LOGS PARA PROVIDERS
  // ========================================

  /// Log de cambio de estado en provider
  static void providerStateChange(
    String providerName,
    String stateName,
    dynamic newValue,
  ) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint(
      '$_yellow[PROVIDER]$_reset $timestamp [$providerName] State: $_bold$stateName$_reset = $newValue',
    );
  }

  /// Log de acción en provider
  static void providerAction(
    String providerName,
    String actionName, {
    Map<String, dynamic>? params,
  }) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint(
      '$_yellow[PROVIDER]$_reset $timestamp [$providerName] Action: $_bold$actionName$_reset',
    );

    if (params != null && params.isNotEmpty) {
      params.forEach((key, value) {
        debugPrint('  └─ $key: $value');
      });
    }
  }

  // ========================================
  // LOGS PARA FILE UPLOAD
  // ========================================

  /// Log de inicio de upload
  static void uploadStart(String filename, int fileSize) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    debugPrint(
      '\n$_magenta$_bold╔════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_magenta$_bold║ FILE UPLOAD START$_reset $timestamp');
    debugPrint(
      '$_magenta$_bold╠════════════════════════════════════════════════════════════$_reset',
    );
    debugPrint('$_magenta║$_reset File: $_bold$filename$_reset');
    debugPrint(
      '$_magenta║$_reset Size: $_bold${sizeMB}MB$_reset ($fileSize bytes)',
    );
    debugPrint(
      '$_magenta$_bold╚════════════════════════════════════════════════════════════$_reset\n',
    );
  }

  /// Log de progreso de upload
  static void uploadProgress(String filename, int sent, int total) {
    if (!enableLogs || !kDebugMode) return;
    final percentage = ((sent / total) * 100).toStringAsFixed(1);
    final sentMB = (sent / (1024 * 1024)).toStringAsFixed(2);
    final totalMB = (total / (1024 * 1024)).toStringAsFixed(2);

    debugPrint(
      '$_cyan[UPLOAD]$_reset [$filename] Progress: $_bold$percentage%$_reset ($sentMB MB / $totalMB MB)',
    );
  }

  /// Log de upload exitoso
  static void uploadSuccess(String filename, {String? documentId}) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint('\n$_green$_bold[UPLOAD SUCCESS]$_reset $timestamp');
    debugPrint('$_green  └─ File: $_bold$filename$_reset');
    if (documentId != null) {
      debugPrint('$_green  └─ Document ID: $documentId$_reset');
    }
  }

  /// Log de error en upload
  static void uploadError(String filename, String error) {
    if (!enableLogs || !kDebugMode) return;
    final timestamp = _getTimestamp();

    debugPrint('\n$_red$_bold[UPLOAD ERROR]$_reset $timestamp');
    debugPrint('$_red  └─ File: $_bold$filename$_reset');
    debugPrint('$_red  └─ Error: $error$_reset');
  }

  // ========================================
  // HELPERS
  // ========================================

  /// Obtiene timestamp formateado
  static String _getTimestamp() {
    final now = DateTime.now();
    return '[${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}]';
  }

  /// Habilitar logs
  static void enable() {
    enableLogs = true;
    info('Logging enabled', tag: 'AppLogger');
  }

  /// Deshabilitar logs
  static void disable() {
    info('Logging disabled', tag: 'AppLogger');
    enableLogs = false;
  }

  /// Log de separador (para organizar visualmente)
  static void separator({String? label}) {
    if (!enableLogs || !kDebugMode) return;

    if (label != null) {
      debugPrint(
        '\n$_white$_bold═══════════════════ $label ═══════════════════$_reset\n',
      );
    } else {
      debugPrint(
        '\n$_white═══════════════════════════════════════════════════════════$_reset\n',
      );
    }
  }
}
