import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/documents_repository.dart';
import '../datasources/documents_local_datasource.dart';
import '../datasources/documents_remote_datasource.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsRemoteDataSource remoteDataSource;
  final DocumentsLocalDataSource localDataSource;

  DocumentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Document>>> getDocuments() async {
    try {
      final documents = await remoteDataSource.getDocuments();

      // Guardar en cache
      await localDataSource.cacheDocuments(documents);

      return Right(documents);
    } on ServerException catch (e) {
      // Si falla, intentar obtener del cache
      try {
        final cachedDocs = await localDataSource.getCachedDocuments();
        if (cachedDocs.isNotEmpty) {
          return Right(cachedDocs);
        }
      } catch (_) {}

      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Sin red, obtener del cache
      try {
        final cachedDocs = await localDataSource.getCachedDocuments();
        return Right(cachedDocs);
      } catch (_) {
        return Left(NetworkFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Document>> getDocumentById(String id) async {
    try {
      final document = await remoteDataSource.getDocumentById(id);
      return Right(document);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Document>> uploadDocument({
    required String filename,
    required List<int> bytes,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final document = await remoteDataSource.uploadDocument(
        filename: filename,
        bytes: bytes,
        onProgress: onProgress,
      );
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      await remoteDataSource.deleteDocument(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> searchDocuments(String query) async {
    try {
      final documents = await remoteDataSource.searchDocuments(query);
      return Right(documents);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<Failure, Document>> watchDocumentStatus(String id) async* {
    // Simulación de polling cada 3 segundos
    while (true) {
      await Future.delayed(const Duration(seconds: 3));

      try {
        final document = await remoteDataSource.getDocumentById(id);
        yield Right(document);

        // Si completó o falló, terminar stream
        if (document.isCompleted || document.hasFailed) {
          break;
        }
      } on Exception catch (e) {
        yield Left(ServerFailure(e.toString()));
        break;
      }
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getCachedDocuments() async {
    try {
      final documents = await localDataSource.getCachedDocuments();
      return Right(documents);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
