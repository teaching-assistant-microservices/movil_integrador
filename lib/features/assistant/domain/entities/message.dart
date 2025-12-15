import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant, system }

class MessageEntity extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final List<MessageSourceEntity> sources;
  final DateTime timestamp;

  const MessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.sources,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;

  @override
  List<Object?> get props => [id, role, content, sources, timestamp];
}

class MessageSourceEntity extends Equatable {
  final String title;
  final String url; // Agregado para robustez futura
  final double relevanceScore;

  const MessageSourceEntity({
    required this.title,
    this.url = '',
    required this.relevanceScore,
  });

  @override
  List<Object?> get props => [title, url, relevanceScore];
}
