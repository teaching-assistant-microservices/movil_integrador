// lib/core/mocks/chat_mock_data.dart
import 'package:integrador/features/assistant/domain/entities/conversation.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import 'package:integrador/features/assistant/domain/entities/stream_event.dart';

class ChatMockData {
  static Stream<StreamEvent> mockStreamResponse(String query) async* {
    // Simular typing delay inicial
    await Future.delayed(Duration(milliseconds: 500));

    // Respuestas predefinidas según keywords
    final response = _generateResponse(query);

    // Simular streaming token por token
    for (int i = 0; i < response.length; i++) {
      await Future.delayed(Duration(milliseconds: 30));

      yield StreamEvent(
        type: StreamEventType.token,
        data: StreamToken(token: response[i], index: i),
      );
    }

    // Simular fuentes documentales
    yield StreamEvent(
      type: StreamEventType.sources,
      data: StreamSources(
        sources: [
          DocumentSourceData(
            documentId: 'doc_001',
            filename: 'Guia_Docente.pdf',
            pageNumber: 12,
            relevanceScore: 0.89,
          ),
        ],
        conversationId: 'mock_conv_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    // Finalizar stream
    yield StreamEvent(
      type: StreamEventType.done,
      data: {'status': 'completed'},
    );
  }

  static String _generateResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('multiplicación') ||
        lowerQuery.contains('matemáticas')) {
      return 'La multiplicación es una operación fundamental en matemáticas. '
          'Según los documentos pedagógicos, se recomienda enseñarla mediante '
          'estrategias visuales y manipulativas. Las tablas de multiplicar son '
          'esenciales para el desarrollo del pensamiento matemático.';
    }

    if (lowerQuery.contains('evaluación') || lowerQuery.contains('evaluar')) {
      return 'Para evaluar el aprendizaje de manera efectiva, se sugiere utilizar '
          'rúbricas claras y objetivos medibles. La evaluación formativa permite '
          'ajustar la enseñanza durante el proceso.';
    }

    // Respuesta genérica
    return 'Basándome en los documentos disponibles, puedo ayudarte con información '
        'sobre estrategias pedagógicas, planificación de clases y recursos educativos. '
        '¿Podrías ser más específico en tu consulta?';
  }

  // Mock de historial de conversaciones
  static List<Conversation> mockConversationHistory() {
    return [
      Conversation(
        conversationId: 'conv_001',
        userId: 'test_user_123',
        title: 'Estrategias de multiplicación',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
        messageCount: 5,
        preview: '¿Cómo enseñar multiplicación en primaria?',
      ),
      Conversation(
        conversationId: 'conv_002',
        userId: 'test_user_123',
        title: 'Evaluación formativa',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 5)),
        messageCount: 3,
        preview: 'Métodos de evaluación continua',
      ),
    ];
  }

  // Mock de mensajes de una conversación
  static List<Message> mockConversationMessages(String conversationId) {
    return [
      Message(
        messageId: 'msg_001',
        content: '¿Cómo enseñar multiplicación en primaria?',
        role: 'user',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 5)),
        sources: [],
      ),
      Message(
        messageId: 'msg_002',
        content:
            'La multiplicación es una operación fundamental en matemáticas. '
            'Según los documentos pedagógicos, se recomienda enseñarla mediante '
            'estrategias visuales y manipulativas.',
        role: 'assistant',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 4)),
        sources: [],
      ),
      Message(
        messageId: 'msg_003',
        content: '¿Qué estrategias visuales recomiendas?',
        role: 'user',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 3)),
        sources: [],
      ),
      Message(
        messageId: 'msg_004',
        content:
            'Se recomiendan usar tableros de multiplicación, manipulativos '
            'concretos y representaciones gráficas para visualizar conceptos.',
        role: 'assistant',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 2)),
        sources: [],
      ),
    ];
  }
}
