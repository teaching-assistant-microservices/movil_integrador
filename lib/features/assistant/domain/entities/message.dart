class Message {
  final String messageId;
  final String role; // 'user' o 'assistant'
  final String content;
  final DateTime timestamp;
  final List<DocumentSource>? sources;

  Message({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Message copyWith({
    String? messageId,
    String? role,
    String? content,
    DateTime? timestamp,
    List<DocumentSource>? sources,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
    );
  }
}

class DocumentSource {
  final String documentId;
  final String filename;
  final int? pageNumber;
  final double? relevanceScore;

  DocumentSource({
    required this.documentId,
    required this.filename,
    this.pageNumber,
    this.relevanceScore,
  });
}
