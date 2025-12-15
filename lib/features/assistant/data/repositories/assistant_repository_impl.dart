// lib/features/assistant/data/repositories/assistant_repository_impl.dart
// ✅ CORREGIDO - Sin streaming, usa JSON responses

import 'package:dartz/dartz.dart';
import 'package:integrador/features/assistant/domain/entities/message.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_datasource.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource remoteDataSource;

  AssistantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> createSession(String userId) async {
    try {
      final sessionId = await remoteDataSource.createSession(userId);
      return Right(sessionId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId,
    required String query,
    bool enableWebSearch = false,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        sessionId: sessionId,
        query: query,
        enableWebSearch: enableWebSearch,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getHistory(
    String sessionId,
  ) async {
    try {
      final result = await remoteDataSource.getHistory(sessionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
