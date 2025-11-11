import 'package:integrador/features/assistant/domain/entities/message.dart';

class MessageDto {
  final String messageId;
  final String role;
  final String content;
  final String timestamp;
  final List<DocumentSourceDto>? sources;

  MessageDto({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      messageId: json['message_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
      sources: json['sources'] != null
          ? (json['sources'] as List)
              .map((e) => DocumentSourceDto.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Message toEntity() {
    return Message(
      messageId: messageId,
      role: role,
      content: content,
      timestamp: DateTime.parse(timestamp),
      sources: sources?.map((s) => s.toEntity()).toList(),
    );
  }
}

class DocumentSourceDto {
  final String documentId;
  final String filename;
  final int? pageNumber;
  final double? relevanceScore;

  DocumentSourceDto({
    required this.documentId,
    required this.filename,
    this.pageNumber,
    this.relevanceScore,
  });

  factory DocumentSourceDto.fromJson(Map<String, dynamic> json) {
    return DocumentSourceDto(
      documentId: json['document_id'] as String,
      filename: json['filename'] as String,
      pageNumber: json['page_number'] as int?,
      relevanceScore: (json['relevance_score'] as num?)?.toDouble(),
    );
  }

  DocumentSource toEntity() {
    return DocumentSource(
      documentId: documentId,
      filename: filename,
      pageNumber: pageNumber,
      relevanceScore: relevanceScore,
    );
  }
}

class ConversationMessagesDto {
  final String conversationId;
  final String userId;
  final List<MessageDto> messages;

  ConversationMessagesDto({
    required this.conversationId,
    required this.userId,
    required this.messages,
  });

  factory ConversationMessagesDto.fromJson(Map<String, dynamic> json) {
    return ConversationMessagesDto(
      conversationId: json['conversation_id'] as String,
      userId: json['user_id'] as String,
      messages: (json['messages'] as List)
          .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
