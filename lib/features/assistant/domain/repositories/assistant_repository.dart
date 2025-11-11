import 'package:integrador/features/assistant/domain/entities/conversation.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import 'package:integrador/features/assistant/domain/entities/stream_event.dart';

/// Contrato del repositorio del asistente
abstract class AssistantRepository {
  /// Envía un mensaje y recibe respuesta en streaming
  Stream<StreamEvent> sendMessage({
    required String userId,
    required String query,
    String? conversationId,
  });

  /// Obtiene el historial de conversaciones del usuario
  Future<List<Conversation>> getConversationHistory({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  /// Obtiene los mensajes de una conversación específica
  Future<List<Message>> getConversationMessages(String conversationId);

  /// Elimina una conversación
  Future<void> deleteConversation(String conversationId);
}