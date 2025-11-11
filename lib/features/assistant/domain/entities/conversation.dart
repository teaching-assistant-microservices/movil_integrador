class Conversation {
  final String conversationId;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final String? preview;

  Conversation({
    required this.conversationId,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.preview,
  });

  Conversation copyWith({
    String? conversationId,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    String? preview,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      preview: preview ?? this.preview,
    );
  }
}
