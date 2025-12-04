// lib/features/assistant/ui/providers/assistant_provider.dart
// VERSIÓN CORREGIDA - Implementa sanitización de mensajes (CRÍTICO)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:integrador/core/utils/validators.dart'; // ⬅️ NUEVO IMPORT CRÍTICO
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

  // 🔒 CORRECCIÓN CRÍTICA: Sanitizar mensaje antes de enviar
  Future<void> sendMessage(String text) async {
    // Validar que no esté vacío
    if (text.trim().isEmpty) return;

    // 🔒 SANITIZACIÓN CRÍTICA: Prevenir Prompt Injection
    final sanitized = InputValidators.sanitizeChatMessage(text);

    // 🔒 VALIDACIÓN ADICIONAL: Verificar longitud después de sanitizar
    final validationError = InputValidators.validateChatMessage(sanitized);
    if (validationError != null) {
      // Mostrar error al usuario
      _messages.add(
        ChatMessage.assistant(message: '⚠️ Error: $validationError'),
      );
      notifyListeners();
      return;
    }

    // Agregar mensaje del usuario (con texto sanitizado)
    final userMessage = ChatMessage.user(message: sanitized);
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    // Enviar mensaje sanitizado a la API
    await _sendMessageToApi(sanitized);
  }

  Future<void> _sendMessageToApi(String query) async {
    // Buffer para acumular los tokens del streaming
    final responseBuffer = StringBuffer();
    String? documentReference;

    _streamSubscription?.cancel();

    _streamSubscription = _repository
        .sendMessage(
          userId: _userId,
          query: query, // Ya viene sanitizado
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
                  _messages.add(
                    ChatMessage.assistant(
                      message: responseBuffer.toString(),
                      documentReference: documentReference,
                    ),
                  );
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
                _messages.add(
                  ChatMessage.assistant(message: 'Error: ${event.data}'),
                );
                notifyListeners();
                break;
            }
          },
          onError: (error) {
            _isTyping = false;
            _messages.add(
              ChatMessage.assistant(
                message:
                    'Error de conexión: $error\n\nVerifica que el servidor esté ejecutándose en http://localhost:8000',
              ),
            );
            notifyListeners();
          },
        );
  }

  // Limpiar conversación
  void clearChat() {
    _messages.clear();
    _currentConversationId = null;
    notifyListeners();
  }

  // 🔒 NUEVA FUNCIÓN: Validar mensaje antes de enviar (para UI)
  String? validateMessage(String message) {
    return InputValidators.validateChatMessage(message);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
