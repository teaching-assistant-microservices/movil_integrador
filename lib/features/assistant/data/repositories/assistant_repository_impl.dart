import 'package:integrador/core/mocks/chat_mock_data.dart';
import 'package:integrador/core/mocks/mock_service.dart';
import 'package:integrador/features/assistant/data/datasources/assistant_api_service.dart';
import 'package:integrador/features/assistant/data/models/chat_request_dto.dart';
import 'package:integrador/features/assistant/domain/entities/conversation.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import 'package:integrador/features/assistant/domain/entities/stream_event.dart';
import 'package:integrador/features/assistant/domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantApiService? _apiService;
  final bool useMockData;

  AssistantRepositoryImpl({
    AssistantApiService? apiService,
    this.useMockData = true, // ⚠️ TRUE por defecto mientras no hay backend
  }) : _apiService = useMockData ? null : (apiService ?? AssistantApiService());

  @override
  Stream<StreamEvent> sendMessage({
    required String userId,
    required String query,
    String? conversationId,
  }) {
    if (useMockData) {
      return ChatMockData.mockStreamResponse(query);
    }

    final request = ChatRequestDto(
      userId: userId,
      query: query,
      conversationId: conversationId,
    );
    return _apiService!.sendMessageStream(request);
  }

  @override
  Future<List<Conversation>> getConversationHistory({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    if (useMockData) {
      return await MockService.simulateApiCall(
        dataGenerator: () => ChatMockData.mockConversationHistory(),
      );
    }

    final dto = await _apiService!.getConversationHistory(
      userId,
      limit: limit,
      offset: offset,
    );
    return dto.conversations.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<Message>> getConversationMessages(String conversationId) async {
    if (useMockData) {
      return await MockService.simulateApiCall(
        dataGenerator: () =>
            ChatMockData.mockConversationMessages(conversationId),
      );
    }

    final dto = await _apiService!.getConversationMessages(conversationId);
    return dto.messages.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    if (useMockData) {
      await MockService.simulateApiCall(dataGenerator: () => null);
      return;
    }

    await _apiService!.deleteConversation(conversationId);
  }
}
