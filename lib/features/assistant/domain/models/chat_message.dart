class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? documentReference; // Referencia a documento fuente (ej: "doc.pdf, pág. 12")

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.documentReference,
  });

  // Factory constructor para mensajes del usuario
  factory ChatMessage.user({
    required String message,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  // Factory constructor para mensajes del asistente
  factory ChatMessage.assistant({
    required String message,
    String? documentReference,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: false,
      timestamp: DateTime.now(),
      documentReference: documentReference,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? message,
    bool? isUser,
    DateTime? timestamp,
    String? documentReference,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      documentReference: documentReference ?? this.documentReference,
    );
  }
}
