// lib/features/assistant/domain/repositories/assistant_repository.dart
// ✅ CORREGIDO - Sin streaming, manejo de sesiones

import 'package:dartz/dartz.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import '../../../../core/errors/failures.dart';

abstract class AssistantRepository {
  /// Crear una sesión de chat para el usuario
  Future<Either<Failure, String>> createSession(String userId);

  /// Enviar un mensaje y recibir respuesta (sin streaming)
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId,
    required String query,
    bool enableWebSearch = false,
  });

  /// Obtener el historial completo de una sesión
  Future<Either<Failure, List<MessageEntity>>> getHistory(String sessionId);

  /// Eliminar una sesión
  Future<Either<Failure, void>> deleteSession(String sessionId);
}
