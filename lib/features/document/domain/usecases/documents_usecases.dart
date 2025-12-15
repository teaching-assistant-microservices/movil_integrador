import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/documents_repository.dart';

// ============================================
// GET DOCUMENTS
// ============================================
class GetDocumentsUseCase implements UseCase<List<Document>, NoParams> {
  final DocumentsRepository repository;

  GetDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(NoParams params) async {
    return await repository.getDocuments();
  }
}

// ============================================
// GET DOCUMENT BY ID
// ============================================
class GetDocumentByIdUseCase implements UseCase<Document, DocumentIdParams> {
  final DocumentsRepository repository;

  GetDocumentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Document>> call(DocumentIdParams params) async {
    return await repository.getDocumentById(params.id);
  }
}

class DocumentIdParams extends Equatable {
  final String id;

  const DocumentIdParams(this.id);

  @override
  List<Object> get props => [id];
}

// ============================================
// UPLOAD DOCUMENT
// ============================================
class UploadDocumentUseCase implements UseCase<Document, UploadParams> {
  final DocumentsRepository repository;

  UploadDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, Document>> call(UploadParams params) async {
    return await repository.uploadDocument(
      filename: params.filename,
      bytes: params.bytes,
      onProgress: params.onProgress,
    );
  }
}

class UploadParams extends Equatable {
  final String filename;
  final List<int> bytes;
  final Function(int sent, int total)? onProgress;

  const UploadParams({
    required this.filename,
    required this.bytes,
    this.onProgress,
  });

  @override
  List<Object?> get props => [filename, bytes];
}

// ============================================
// DELETE DOCUMENT
// ============================================
class DeleteDocumentUseCase implements UseCase<void, DocumentIdParams> {
  final DocumentsRepository repository;

  DeleteDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DocumentIdParams params) async {
    return await repository.deleteDocument(params.id);
  }
}

// ============================================
// SEARCH DOCUMENTS
// ============================================
class SearchDocumentsUseCase implements UseCase<List<Document>, SearchParams> {
  final DocumentsRepository repository;

  SearchDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(SearchParams params) async {
    return await repository.searchDocuments(params.query);
  }
}

class SearchParams extends Equatable {
  final String query;

  const SearchParams(this.query);

  @override
  List<Object> get props => [query];
}

// ============================================
// WATCH DOCUMENT STATUS (Stream)
// ============================================
class WatchDocumentStatusUseCase
    implements StreamUseCase<Document, DocumentIdParams> {
  final DocumentsRepository repository;

  WatchDocumentStatusUseCase(this.repository);

  @override
  Stream<Either<Failure, Document>> call(DocumentIdParams params) {
    return repository.watchDocumentStatus(params.id);
  }
}
