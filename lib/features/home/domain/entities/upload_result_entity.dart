class UploadResultEntity {
  final bool success;
  final String message;
  final String? documentId;
  final String? filename;

  UploadResultEntity({
    required this.success,
    required this.message,
    this.documentId,
    this.filename,
  });
}