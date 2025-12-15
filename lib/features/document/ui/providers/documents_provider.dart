// lib/features/documents/presentation/providers/documents_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/document.dart';
import '../../domain/usecases/documents_usecases.dart';

/// Estados posibles de la gestión de documentos
enum DocumentsStatus { initial, loading, uploading, success, error }

/// ViewModel de Documentos usando Provider (MVVM)
///
/// Responsabilidades:
/// - Gestionar estado de UI
/// - Coordinar use cases
/// - Exponer datos de forma reactiva
/// - NO contiene lógica de negocio (eso está en UseCases)
class DocumentsProvider extends ChangeNotifier {
  // Dependencies (Use Cases)
  final GetDocumentsUseCase getDocumentsUseCase;
  final GetDocumentByIdUseCase getDocumentByIdUseCase;
  final UploadDocumentUseCase uploadDocumentUseCase;
  final DeleteDocumentUseCase deleteDocumentUseCase;
  final SearchDocumentsUseCase searchDocumentsUseCase;
  final WatchDocumentStatusUseCase watchDocumentStatusUseCase;

  DocumentsProvider({
    required this.getDocumentsUseCase,
    required this.getDocumentByIdUseCase,
    required this.uploadDocumentUseCase,
    required this.deleteDocumentUseCase,
    required this.searchDocumentsUseCase,
    required this.watchDocumentStatusUseCase,
  });

  // ========================================
  // STATE
  // ========================================

  DocumentsStatus _status = DocumentsStatus.initial;
  DocumentsStatus get status => _status;

  List<Document> _documents = [];
  List<Document> get documents => List.unmodifiable(_documents);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  // Estado de búsqueda
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Document> _filteredDocuments = [];
  List<Document> get filteredDocuments => List.unmodifiable(_filteredDocuments);

  // Monitoreo de documentos en procesamiento
  final Map<String, StreamSubscription> _watchSubscriptions = {};

  bool get isLoading => _status == DocumentsStatus.loading;
  bool get isUploading => _status == DocumentsStatus.uploading;
  bool get hasError => _status == DocumentsStatus.error;
  bool get isEmpty => _documents.isEmpty;

  // Estadísticas útiles
  int get totalDocuments => _documents.length;
  int get completedDocuments =>
      _documents.where((doc) => doc.isCompleted).length;
  int get processingDocuments =>
      _documents.where((doc) => doc.isProcessing).length;

  // ========================================
  // LOAD DOCUMENTS
  // ========================================

  Future<void> loadDocuments() async {
    _setStatus(DocumentsStatus.loading);
    _errorMessage = null;

    AppLogger.info('Cargando documentos', tag: 'DocumentsProvider');

    final result = await getDocumentsUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(DocumentsStatus.error);
        AppLogger.error(
          'Error al cargar documentos',
          tag: 'DocumentsProvider',
          error: failure,
        );
      },
      (documents) {
        _documents = documents;
        _filteredDocuments = documents;
        _setStatus(DocumentsStatus.success);

        AppLogger.success(
          '${documents.length} documentos cargados',
          tag: 'DocumentsProvider',
        );

        // Iniciar monitoreo de documentos en procesamiento
        _startWatchingProcessingDocuments();
      },
    );
  }

  // ========================================
  // GET DOCUMENT BY ID
  // ========================================

  Future<Document?> getDocumentById(String id) async {
    AppLogger.info('Obteniendo documento: $id', tag: 'DocumentsProvider');

    final result = await getDocumentByIdUseCase(DocumentIdParams(id));

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppLogger.error(
          'Error al obtener documento',
          tag: 'DocumentsProvider',
          error: failure,
        );
        return null;
      },
      (document) {
        AppLogger.success(
          'Documento obtenido: ${document.filename}',
          tag: 'DocumentsProvider',
        );
        return document;
      },
    );
  }

  // ========================================
  // UPLOAD DOCUMENT
  // ========================================

  Future<bool> uploadDocument({
    required String filename,
    required List<int> bytes,
  }) async {
    _setStatus(DocumentsStatus.uploading);
    _uploadProgress = 0.0;
    _errorMessage = null;

    AppLogger.uploadStart(filename, bytes.length);

    final result = await uploadDocumentUseCase(
      UploadParams(
        filename: filename,
        bytes: bytes,
        onProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
          AppLogger.uploadProgress(filename, sent, total);
        },
      ),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(DocumentsStatus.error);
        AppLogger.uploadError(filename, failure.message);
        return false;
      },
      (document) {
        // Agregar documento a la lista
        _documents = [document, ..._documents];
        _filteredDocuments = _documents;
        _setStatus(DocumentsStatus.success);

        AppLogger.uploadSuccess(filename, documentId: document.id);

        // Si está en procesamiento, iniciar monitoreo
        if (document.isProcessing) {
          _startWatchingDocument(document.id);
        }

        return true;
      },
    );
  }

  // ========================================
  // DELETE DOCUMENT
  // ========================================

  Future<bool> deleteDocument(String documentId) async {
    AppLogger.info(
      'Eliminando documento: $documentId',
      tag: 'DocumentsProvider',
    );

    final result = await deleteDocumentUseCase(DocumentIdParams(documentId));

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppLogger.error(
          'Error al eliminar documento',
          tag: 'DocumentsProvider',
          error: failure,
        );
        return false;
      },
      (_) {
        // Remover de la lista
        _documents = _documents.where((doc) => doc.id != documentId).toList();
        _filteredDocuments = _filteredDocuments
            .where((doc) => doc.id != documentId)
            .toList();

        // Cancelar monitoreo si existe
        _stopWatchingDocument(documentId);

        notifyListeners();

        AppLogger.success('Documento eliminado', tag: 'DocumentsProvider');
        return true;
      },
    );
  }

  // ========================================
  // SEARCH DOCUMENTS
  // ========================================

  Future<void> searchDocuments(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredDocuments = _documents;
      notifyListeners();
      return;
    }

    AppLogger.info('Buscando: "$query"', tag: 'DocumentsProvider');

    final result = await searchDocumentsUseCase(SearchParams(query));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        // En caso de error, filtrar localmente
        final queryLower = query.toLowerCase();
        _filteredDocuments = _documents
            .where((doc) => doc.filename.toLowerCase().contains(queryLower))
            .toList();
      },
      (documents) {
        _filteredDocuments = documents;
      },
    );

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredDocuments = _documents;
    notifyListeners();
  }

  // ========================================
  // WATCH DOCUMENT STATUS (Streaming)
  // ========================================

  void _startWatchingDocument(String documentId) {
    // No crear múltiples subscripciones para el mismo documento
    if (_watchSubscriptions.containsKey(documentId)) return;

    AppLogger.streamStart('DocumentStatus', params: {'documentId': documentId});

    final stream = watchDocumentStatusUseCase(DocumentIdParams(documentId));

    final subscription = stream.listen(
      (either) {
        either.fold(
          (failure) {
            AppLogger.streamError('DocumentStatus', failure);
          },
          (updatedDoc) {
            // Actualizar documento en la lista
            final index = _documents.indexWhere((d) => d.id == documentId);
            if (index != -1) {
              _documents[index] = updatedDoc;

              // También actualizar en filtrados
              final filteredIndex = _filteredDocuments.indexWhere(
                (d) => d.id == documentId,
              );
              if (filteredIndex != -1) {
                _filteredDocuments[filteredIndex] = updatedDoc;
              }

              notifyListeners();

              AppLogger.streamEvent('DocumentStatus', 'StatusUpdate', {
                'status': updatedDoc.status,
              });

              // Si terminó de procesar, detener monitoreo
              if (updatedDoc.isCompleted || updatedDoc.hasFailed) {
                _stopWatchingDocument(documentId);
                AppLogger.streamDone('DocumentStatus');
              }
            }
          },
        );
      },
      onError: (error) {
        AppLogger.streamError('DocumentStatus', error);
        _stopWatchingDocument(documentId);
      },
      onDone: () {
        AppLogger.streamDone('DocumentStatus');
        _stopWatchingDocument(documentId);
      },
    );

    _watchSubscriptions[documentId] = subscription;
  }

  void _stopWatchingDocument(String documentId) {
    _watchSubscriptions[documentId]?.cancel();
    _watchSubscriptions.remove(documentId);
  }

  void _startWatchingProcessingDocuments() {
    for (final doc in _documents) {
      if (doc.isProcessing) {
        _startWatchingDocument(doc.id);
      }
    }
  }

  // ========================================
  // HELPERS
  // ========================================

  void _setStatus(DocumentsStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========================================
  // DISPOSE
  // ========================================

  @override
  void dispose() {
    // Cancelar todas las subscripciones
    for (final subscription in _watchSubscriptions.values) {
      subscription.cancel();
    }
    _watchSubscriptions.clear();
    super.dispose();
  }
}
