// lib/features/assistant/data/datasources/assistant_remote_datasource.dart
// ✅ CORREGIDO - Usa endpoints reales de Core IA

import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';

abstract class AssistantRemoteDataSource {
  /// Crear sesión de chat
  Future<String> createSession(String userId);

  /// Enviar mensaje y obtener respuesta
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String query,
    bool enableWebSearch = false,
  });

  /// Obtener historial de una sesión
  Future<List<MessageModel>> getHistory(String sessionId);

  /// Eliminar sesión
  Future<void> deleteSession(String sessionId);
}

class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {
  final Dio dio;

  AssistantRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> createSession(String userId) async {
    try {
      AppLogger.info(
        'Creando sesión de chat para user: $userId',
        tag: 'AssistantDS',
      );

      // POST /api/v1/chat/sessions
      final response = await dio.post(
        AppConfig.chatSessionsUrl,
        data: {
          'user_id': userId,
          'session_name': 'Chat ${DateTime.now().toIso8601String()}',
        },
      );

      if (response.statusCode == 201) {
        final sessionId = response.data['data']['id'] as String;
        AppLogger.success('Sesión creada: $sessionId', tag: 'AssistantDS');
        return sessionId;
      } else {
        throw ServerException(message: 'Error al crear sesión de chat');
      }
    } on DioException catch (e) {
      AppLogger.error('Error al crear sesión', tag: 'AssistantDS', error: e);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Error al crear sesión',
      );
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String query,
    bool enableWebSearch = false,
  }) async {
    try {
      AppLogger.info(
        'Enviando mensaje a sesión $sessionId',
        tag: 'AssistantDS',
      );

      // POST /api/v1/chat/sessions/{session_id}/query
      final response = await dio.post(
        AppConfig.chatQueryUrl(sessionId),
        data: {
          'query': query,
          'top_k': 5,
          'threshold': 0.3,
          'enable_web_search': enableWebSearch,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        AppLogger.success('Respuesta recibida', tag: 'AssistantDS');

        // Mapear a MessageModel
        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: data['response'] as String,
          sources: _parseSources(data['sources']),
          timestamp: DateTime.now(),
        );
      } else {
        throw ServerException(message: 'Error al enviar mensaje');
      }
    } on DioException catch (e) {
      AppLogger.error('Error al enviar mensaje', tag: 'AssistantDS', error: e);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Error al enviar mensaje',
      );
    }
  }

  @override
  Future<List<MessageModel>> getHistory(String sessionId) async {
    try {
      AppLogger.info(
        'Obteniendo historial de sesión $sessionId',
        tag: 'AssistantDS',
      );

      // GET /api/v1/chat/sessions/{session_id}/history
      final response = await dio.get(
        AppConfig.chatHistoryUrl(sessionId),
        queryParameters: {'limit': 50},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final messages = data['messages'] as List;

        AppLogger.success(
          'Historial obtenido: ${messages.length} mensajes',
          tag: 'AssistantDS',
        );

        return messages.map((json) => _parseHistoryMessage(json)).toList();
      } else {
        throw ServerException(message: 'Error al obtener historial');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error al obtener historial',
        tag: 'AssistantDS',
        error: e,
      );
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Error al obtener historial',
      );
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      AppLogger.info('Eliminando sesión $sessionId', tag: 'AssistantDS');

      // DELETE /api/v1/chat/sessions/{session_id}
      final response = await dio.delete(
        AppConfig.chatSessionByIdUrl(sessionId),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        AppLogger.success('Sesión eliminada', tag: 'AssistantDS');
      } else {
        throw ServerException(message: 'Error al eliminar sesión');
      }
    } on DioException catch (e) {
      AppLogger.error('Error al eliminar sesión', tag: 'AssistantDS', error: e);
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Error al eliminar sesión',
      );
    }
  }

  // ========================================
  // HELPERS
  // ========================================

  List<MessageSourceModel> _parseSources(dynamic sources) {
    if (sources == null) return [];

    if (sources is List) {
      return sources
          .map(
            (s) => MessageSourceModel(
              title: s.toString(),
              url: '',
              relevanceScore: 0.8,
            ),
          )
          .toList();
    }

    return [];
  }

  MessageModel _parseHistoryMessage(Map<String, dynamic> json) {
    return MessageModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      role: _parseRole(json['role']),
      content: json['content'] as String? ?? '',
      sources: _parseSources(json['context_documents']),
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  MessageRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.assistant;
    }
  }
}
