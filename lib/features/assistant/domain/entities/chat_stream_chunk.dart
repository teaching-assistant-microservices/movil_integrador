import 'package:equatable/equatable.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';

class ChatStreamChunk extends Equatable {
  final String delta;
  final bool isFinal;
  final List<MessageSourceEntity>? sources;
  final bool webSearchNeeded;
  final String? webSearchMessage;

  const ChatStreamChunk({
    required this.delta,
    required this.isFinal,
    this.sources,
    this.webSearchNeeded = false,
    this.webSearchMessage,
  });

  @override
  List<Object?> get props => [delta, isFinal, sources, webSearchNeeded];
}
