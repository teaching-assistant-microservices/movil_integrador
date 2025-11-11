import 'package:integrador/features/assistant/data/datasources/assistant_api_service.dart';
import 'package:integrador/features/assistant/data/models/chat_request_dto.dart';
import 'package:integrador/features/assistant/domain/entities/conversation.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import 'package:integrador/features/assistant/domain/entities/stream_event.dart';
import 'package:integrador/features/assistant/domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantApiService _apiService;

  AssistantRepositoryImpl({AssistantApiService? apiService})
      : _apiService = apiService ?? AssistantApiService();

  @override
  Stream<StreamEvent> sendMessage({
    required String userId,
    required String query,
    String? conversationId,
  }) {
    final request = ChatRequestDto(
      userId: userId,
      query: query,
      conversationId: conversationId,
    );

    return _apiService.sendMessageStream(request);
  }

  @override
  Future<List<Conversation>> getConversationHistory({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _apiService.getConversationHistory(
      userId,
      limit: limit,
      offset: offset,
    );

    return dto.conversations.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<Message>> getConversationMessages(String conversationId) async {
    final dto = await _apiService.getConversationMessages(conversationId);
    return dto.messages.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _apiService.deleteConversation(conversationId);
  }
}