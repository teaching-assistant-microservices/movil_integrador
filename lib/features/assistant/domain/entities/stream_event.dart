/// Representa un evento del streaming SSE
class StreamEvent {
  final StreamEventType type;
  final dynamic data;

  StreamEvent({
    required this.type,
    required this.data,
  });
}

enum StreamEventType {
  token,    // Fragmento de texto
  sources,  // Referencias documentales
  error,    // Error durante procesamiento
  done,     // Streaming completado
}

/// Token individual del streaming
class StreamToken {
  final String token;
  final int index;

  StreamToken({
    required this.token,
    required this.index,
  });
}

/// Fuentes documentales del streaming
class StreamSources {
  final List<DocumentSourceData> sources;
  final String? conversationId;

  StreamSources({
    required this.sources,
    this.conversationId,
  });
}

class DocumentSourceData {
  final String documentId;
  final String filename;
  final int? pageNumber;
  final double? relevanceScore;

  DocumentSourceData({
    required this.documentId,
    required this.filename,
    this.pageNumber,
    this.relevanceScore,
  });
}
