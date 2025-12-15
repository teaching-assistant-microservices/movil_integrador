import 'package:equatable/equatable.dart';

/// Entidad: Documento
class Document extends Equatable {
  final String id;
  final String filename;
  final String status; // PENDING, PROCESSING, COMPLETED, FAILED
  final int size; // bytes
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? errorMessage;

  const Document({
    required this.id,
    required this.filename,
    required this.status,
    required this.size,
    required this.createdAt,
    this.updatedAt,
    this.errorMessage,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isProcessing => status.toUpperCase() == 'PROCESSING';
  bool get hasFailed => status.toUpperCase() == 'FAILED';

  @override
  List<Object?> get props => [
    id,
    filename,
    status,
    size,
    createdAt,
    updatedAt,
    errorMessage,
  ];
}
