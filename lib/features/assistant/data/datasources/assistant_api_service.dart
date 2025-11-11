import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:integrador/core/network/api_services.dart';
import 'package:integrador/features/assistant/data/models/chat_request_dto.dart';
import 'package:integrador/features/assistant/data/models/conversation_dto.dart';
import 'package:integrador/features/assistant/data/models/message_dto.dart';
import 'package:integrador/features/assistant/domain/entities/stream_event.dart';
import 'dart:typed_data';
class AssistantApiService {
  final ApiService _apiService;
  final Dio _dio; // Instancia separada para streaming y uploads
  final String baseUrl;

  static final AssistantApiService _instance = AssistantApiService._internal();
  factory AssistantApiService({
    String baseUrl = 'http://localhost:8000',
  }) {
    _instance._setBaseUrl(baseUrl);
    return _instance;
  }

  AssistantApiService._internal()
      : _apiService = ApiService(),
        baseUrl = 'http://localhost:8000',
        _dio = Dio(BaseOptions(
          baseUrl: 'http://localhost:8000',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ));

  void _setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }


  Stream<StreamEvent> sendMessageStream(ChatRequestDto request) async* {

    final controller = StreamController<StreamEvent>();

    try {
      final response = await _dio.post(
        '/chat/stream',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );


      final bytesBuilder = BytesBuilder(); 
      
      response.data!.stream.listen(
        (Uint8List chunk) {
          bytesBuilder.add(chunk);
          final buffer = utf8.decode(bytesBuilder.toBytes(), allowMalformed: true);
          final lines = buffer.split('\n');

          // Procesamos todas las líneas completas excepto la última (que podría estar incompleta)
          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i];
            if (line.isEmpty) continue;
            if (line.startsWith('event:') && line.contains('keep-alive')) continue;

            if (line.startsWith('data:')) {
              final jsonData = line.substring(5).trim();
              if (jsonData.isEmpty) continue;

              try {
                final data = jsonDecode(jsonData);
                controller.add(_parseStreamEvent(data));
              } catch (e) {
                controller.add(StreamEvent(
                  type: StreamEventType.error,
                  data: 'Error parsing stream data: $e',
                ));
              }
            }
          }

          // Mantenemos solo la última línea (potencialmente incompleta) para la próxima iteración
          final lastLine = lines.last;
          bytesBuilder.clear();
          bytesBuilder.add(utf8.encoder.convert(lastLine));
        },
        onDone: () {
          controller.close();
        },
        onError: (error) {
          controller.add(StreamEvent(
            type: StreamEventType.error,
            data: 'Stream error: $error',
          ));
          controller.close();
        },
      );
      // ----------------------------------------------------------------------

      // Yield los eventos del controller al stream que devuelve esta función
      yield* controller.stream;

    } on DioException catch (e) {
      String errorMessage = 'Connection error';
      if (e.response != null) {
        if (e.response?.statusCode == 422) {
          errorMessage = 'Validation Error: Please check your request data';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Endpoint not found. Please check the API URL';
        } else {
          errorMessage = 'Server error: ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout';
      }
      
      yield StreamEvent(
        type: StreamEventType.error,
        data: errorMessage,
      );
    } catch (e) {
      yield StreamEvent(
        type: StreamEventType.error,
        data: 'Unexpected error: $e',
      );
    }
  }

  // Helper para separar la lógica de parsing
  StreamEvent _parseStreamEvent(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'content':
        return StreamEvent(
          type: StreamEventType.token,
          data: StreamToken(
            token: data['content'] as String,
            index: 0,
          ),
        );
      case 'sources':
        return StreamEvent(
          type: StreamEventType.sources,
          data: StreamSources(
            sources: (data['content'] as List?)
                    ?.map((s) => DocumentSourceData(
                          documentId: s['document_id'] as String? ?? '',
                          filename: s['filename'] as String? ?? '',
                          pageNumber: s['page_number'] as int?,
                          relevanceScore: (s['relevance_score'] as num?)?.toDouble(),
                        ))
                    .toList() ??
                [],
            conversationId: data['session_id'] as String?,
          ),
        );
      case 'done':
        return StreamEvent(
          type: StreamEventType.done,
          data: data,
        );
      case 'error':
        return StreamEvent(
          type: StreamEventType.error,
          data: data['content'] as String? ?? 'Unknown error',
        );
      default:
        return StreamEvent(
          type: StreamEventType.error,
          data: 'Unknown event type: ${data['type']}',
        );
    }
  }


  /// 1.2 Obtener Historial de Conversaciones
  /// GET /chat/history/{user_id}
  Future<ConversationHistoryDto> getConversationHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return await _apiService.get(
      '$baseUrl/chat/history/$userId',
      queryParameters: {'limit': limit, 'offset': offset},
      fromJson: (json) => ConversationHistoryDto.fromJson(json),
    );
  }

  /// 1.3 Obtener Mensajes de una Conversación
  /// GET /chat/conversation/{conversation_id}
  Future<ConversationMessagesDto> getConversationMessages(
    String conversationId,
  ) async {
    return await _apiService.get(
      '$baseUrl/chat/conversation/$conversationId',
      fromJson: (json) => ConversationMessagesDto.fromJson(json),
    );
  }

  /// 1.4 Eliminar Conversación
  /// DELETE /chat/conversation/{conversation_id}
  Future<void> deleteConversation(String conversationId) async {
    await _apiService.delete(
      '$baseUrl/chat/conversation/$conversationId',
      fromJson: (_) => {},
    );
  }


}