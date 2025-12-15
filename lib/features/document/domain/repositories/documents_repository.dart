import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document.dart';

abstract class DocumentsRepository {
  /// Obtener lista de documentos
  Future<Either<Failure, List<Document>>> getDocuments();

  /// Obtener documento por ID
  Future<Either<Failure, Document>> getDocumentById(String id);

  /// Subir documento
  Future<Either<Failure, Document>> uploadDocument({
    required String filename,
    required List<int> bytes,
    Function(int sent, int total)? onProgress,
  });

  /// Eliminar documento
  Future<Either<Failure, void>> deleteDocument(String id);

  /// Buscar documentos
  Future<Either<Failure, List<Document>>> searchDocuments(String query);

  /// Monitorear estado de documento (stream)
  Stream<Either<Failure, Document>> watchDocumentStatus(String id);

  /// Obtener documentos del cache
  Future<Either<Failure, List<Document>>> getCachedDocuments();
}
