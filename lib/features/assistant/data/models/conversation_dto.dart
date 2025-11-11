import 'package:integrador/features/assistant/domain/entities/conversation.dart';

class ConversationDto {
  final String conversationId;
  final String userId;
  final String title;
  final String createdAt;
  final String updatedAt;
  final int messageCount;
  final String? preview;

  ConversationDto({
    required this.conversationId,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.preview,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      conversationId: json['conversation_id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      messageCount: json['message_count'] as int,
      preview: json['preview'] as String?,
    );
  }

  Conversation toEntity() {
    return Conversation(
      conversationId: conversationId,
      userId: userId,
      title: title,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      messageCount: messageCount,
      preview: preview,
    );
  }
}

class ConversationHistoryDto {
  final List<ConversationDto> conversations;
  final int total;
  final int limit;
  final int offset;

  ConversationHistoryDto({
    required this.conversations,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ConversationHistoryDto.fromJson(Map<String, dynamic> json) {
    return ConversationHistoryDto(
      conversations: (json['conversations'] as List)
          .map((e) => ConversationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }
}
