// lib/features/assistant/ui/providers/assistant_provider.dart
// ✅ CORREGIDO - Sin streaming, manejo de sesiones

import 'package:flutter/foundation.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import '../../domain/usecases/assistant_usecases.dart';
import '../../../../core/utils/logger.dart';

enum AssistantStatus { initial, loading, success, error }

class AssistantProvider extends ChangeNotifier {
  final CreateSessionUseCase createSessionUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetHistoryUseCase getHistoryUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;

  AssistantProvider({
    required this.createSessionUseCase,
    required this.sendMessageUseCase,
    required this.getHistoryUseCase,
    required this.deleteSessionUseCase,
  });

  // ========================================
  // STATE
  // ========================================

  List<MessageEntity> _messages = [];
  List<MessageEntity> get messages => List.unmodifiable(_messages);

  AssistantStatus _status = AssistantStatus.initial;
  AssistantStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  bool get isLoading => _status == AssistantStatus.loading;
  bool get hasSession => _currentSessionId != null;

  // ========================================
  // INITIALIZE
  // ========================================

  Future<void> initialize({required String userId}) async {
    AppLogger.info('Inicializando AssistantProvider', tag: 'AssistantProvider');

    // Crear sesión automáticamente
    await _createSession(userId);
  }

  // ========================================
  // CREATE SESSION (PRIVADO)
  // ========================================

  Future<void> _createSession(String userId) async {
    _setStatus(AssistantStatus.loading);

    final result = await createSessionUseCase(
      CreateSessionParams(userId: userId),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AssistantStatus.error);
        AppLogger.error(
          'Error al crear sesión',
          tag: 'AssistantProvider',
          error: failure,
        );
      },
      (sessionId) {
        _currentSessionId = sessionId;
        _setStatus(AssistantStatus.success);
        AppLogger.success(
          'Sesión creada: $sessionId',
          tag: 'AssistantProvider',
        );

        // Cargar historial si existe
        _loadHistory();
      },
    );
  }

  // ========================================
  // LOAD HISTORY
  // ========================================

  Future<void> _loadHistory() async {
    if (_currentSessionId == null) return;

    final result = await getHistoryUseCase(
      GetHistoryParams(sessionId: _currentSessionId!),
    );

    result.fold(
      (failure) {
        AppLogger.warning(
          'No se pudo cargar historial: ${failure.message}',
          tag: 'AssistantProvider',
        );
      },
      (history) {
        _messages = history;
        notifyListeners();
        AppLogger.success(
          'Historial cargado: ${history.length} mensajes',
          tag: 'AssistantProvider',
        );
      },
    );
  }

  // ========================================
  // SEND MESSAGE
  // ========================================

  Future<void> sendMessage({
    required String query,
    bool enableWebSearch = false,
  }) async {
    if (query.trim().isEmpty) return;

    // Si no hay sesión, crear una con un userId dummy
    if (_currentSessionId == null) {
      await _createSession('user_${DateTime.now().millisecondsSinceEpoch}');
      if (_currentSessionId == null) {
        _errorMessage = 'No se pudo crear sesión de chat';
        _setStatus(AssistantStatus.error);
        return;
      }
    }

    // 1. Agregar mensaje del usuario
    final userMsg = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: query,
      sources: const [],
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _setStatus(AssistantStatus.loading);

    AppLogger.info(
      'Enviando mensaje: ${query.substring(0, query.length > 50 ? 50 : query.length)}...',
      tag: 'AssistantProvider',
    );

    // 2. Enviar al backend
    final result = await sendMessageUseCase(
      SendMessageParams(
        sessionId: _currentSessionId!,
        query: query,
        enableWebSearch: enableWebSearch,
      ),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AssistantStatus.error);
        AppLogger.error(
          'Error al enviar mensaje',
          tag: 'AssistantProvider',
          error: failure,
        );
      },
      (assistantMessage) {
        _messages.add(assistantMessage);
        _setStatus(AssistantStatus.success);
        AppLogger.success('Respuesta recibida', tag: 'AssistantProvider');
      },
    );
  }

  // ========================================
  // CLEAR HISTORY (ELIMINAR SESIÓN)
  // ========================================

  Future<void> clearHistory({required String userId}) async {
    if (_currentSessionId == null) return;

    final result = await deleteSessionUseCase(
      DeleteSessionParams(sessionId: _currentSessionId!),
    );

    result.fold(
      (failure) {
        AppLogger.warning(
          'Error al eliminar sesión: ${failure.message}',
          tag: 'AssistantProvider',
        );
      },
      (_) {
        AppLogger.success('Sesión eliminada', tag: 'AssistantProvider');
      },
    );

    // Limpiar estado local
    _messages.clear();
    _currentSessionId = null;
    _setStatus(AssistantStatus.initial);

    // Crear nueva sesión
    await _createSession(userId);
  }

  // ========================================
  // HELPERS
  // ========================================

  void _setStatus(AssistantStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
