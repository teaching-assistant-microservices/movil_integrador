// lib/features/assistant/domain/usecases/assistant_usecases.dart
// ✅ CORREGIDO - Use cases actualizados

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/assistant_repository.dart';

// ============================================
// CREATE SESSION USE CASE
// ============================================
class CreateSessionUseCase implements UseCase<String, CreateSessionParams> {
  final AssistantRepository repository;

  CreateSessionUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateSessionParams params) async {
    return await repository.createSession(params.userId);
  }
}

class CreateSessionParams extends Equatable {
  final String userId;

  const CreateSessionParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

// ============================================
// SEND MESSAGE USE CASE
// ============================================
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final AssistantRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      sessionId: params.sessionId,
      query: params.query,
      enableWebSearch: params.enableWebSearch,
    );
  }
}

class SendMessageParams extends Equatable {
  final String sessionId;
  final String query;
  final bool enableWebSearch;

  const SendMessageParams({
    required this.sessionId,
    required this.query,
    this.enableWebSearch = false,
  });

  @override
  List<Object> get props => [sessionId, query, enableWebSearch];
}

// ============================================
// GET HISTORY USE CASE
// ============================================
class GetHistoryUseCase
    implements UseCase<List<MessageEntity>, GetHistoryParams> {
  final AssistantRepository repository;

  GetHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageEntity>>> call(
    GetHistoryParams params,
  ) async {
    return await repository.getHistory(params.sessionId);
  }
}

class GetHistoryParams extends Equatable {
  final String sessionId;

  const GetHistoryParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

// ============================================
// DELETE SESSION USE CASE
// ============================================
class DeleteSessionUseCase implements UseCase<void, DeleteSessionParams> {
  final AssistantRepository repository;

  DeleteSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSessionParams params) async {
    return await repository.deleteSession(params.sessionId);
  }
}

class DeleteSessionParams extends Equatable {
  final String sessionId;

  const DeleteSessionParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
