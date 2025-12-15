import 'package:integrador/features/assistant/domain/entities/message.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.sources,
    required super.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      role: _parseRole(json['role']),
      content: json['content'] as String? ?? '',
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((e) => MessageSourceModel.fromJson(e))
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  static MessageRole _parseRole(String? role) {
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

class MessageSourceModel extends MessageSourceEntity {
  const MessageSourceModel({
    required super.title,
    super.url,
    required super.relevanceScore,
  });

  factory MessageSourceModel.fromJson(Map<String, dynamic> json) {
    return MessageSourceModel(
      title: json['title'] as String? ?? 'Fuente desconocida',
      url: json['url'] as String? ?? '',
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
