import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:integrador/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:integrador/features/assistant/domain/entities/stream_event.dart';
import 'package:integrador/features/assistant/domain/models/chat_message.dart';
import 'package:integrador/features/assistant/domain/repositories/assistant_repository.dart';

class AssistantProvider extends ChangeNotifier {
  final AssistantRepository _repository = AssistantRepositoryImpl();
  
  // Estado
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _currentConversationId;
  StreamSubscription? _streamSubscription;
  
  // Getters para el estado
  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get currentConversationId => _currentConversationId;
  
  // Usuario de prueba según la documentación
  static const String _userId = 'test_user_123';
  
  // Enviar mensaje
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Agregar mensaje del usuario
    final userMessage = ChatMessage.user(message: text);
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();
    
    // Enviar mensaje a la API real
    await _sendMessageToApi(text);
  }
  
  Future<void> _sendMessageToApi(String query) async {
    // Buffer para acumular los tokens del streaming
    final responseBuffer = StringBuffer();
    String? documentReference;
    
    _streamSubscription?.cancel();
    
    _streamSubscription = _repository
        .sendMessage(
          userId: _userId,
          query: query,
          conversationId: _currentConversationId,
        )
        .listen(
      (event) {
        switch (event.type) {
          case StreamEventType.token:
            // Acumular tokens
            final token = event.data as StreamToken;
            responseBuffer.write(token.token);
            
            // Actualizar el último mensaje del asistente o crear uno nuevo
            if (_messages.isNotEmpty && !_messages.last.isUser) {
              // Actualizar el mensaje existente
              _messages.last = ChatMessage.assistant(
                message: responseBuffer.toString(),
                documentReference: documentReference,
              );
            } else {
              // Crear nuevo mensaje del asistente
              _messages.add(ChatMessage.assistant(
                message: responseBuffer.toString(),
                documentReference: documentReference,
              ));
            }
            notifyListeners();
            break;
            
          case StreamEventType.sources:
            final sources = event.data as StreamSources;
            
            // Guardar el ID de la conversación para futuras consultas
            if (sources.conversationId != null) {
              _currentConversationId = sources.conversationId;
            }
            
            // Formatear referencias documentales
            if (sources.sources.isNotEmpty) {
              final firstSource = sources.sources.first;
              documentReference = firstSource.pageNumber != null
                  ? '${firstSource.filename}, pág. ${firstSource.pageNumber}'
                  : firstSource.filename;
              
              // Actualizar el mensaje con las fuentes
              if (_messages.isNotEmpty && !_messages.last.isUser) {
                _messages.last = ChatMessage.assistant(
                  message: responseBuffer.toString(),
                  documentReference: documentReference,
                );
              }
              notifyListeners();
            }
            break;
            
          case StreamEventType.done:
            _isTyping = false;
            notifyListeners();
            break;
            
          case StreamEventType.error:
            _isTyping = false;
            _messages.add(ChatMessage.assistant(
              message: 'Error: ${event.data}',
            ));
            notifyListeners();
            break;
        }
      },
      onError: (error) {
        _isTyping = false;
        _messages.add(ChatMessage.assistant(
          message: 'Error de conexión: $error\n\nVerifica que el servidor esté ejecutándose en http://localhost:8000',
        ));
        notifyListeners();
      },
    );
  }
  
  // Limpiar conversación
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}