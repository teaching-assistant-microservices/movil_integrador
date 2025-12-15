// ========================================
// PANTALLA 2: UploadDocumentScreen
// lib/features/document/ui/screens/upload_document_screen.dart
// ========================================
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/common/widgets/detail_scaffold.dart';
import 'package:integrador/core/network/models/upload_file.dart';
import 'package:integrador/core/network/services/upload_service.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/core/utils/logger.dart';
import 'package:integrador/core/utils/validators.dart';
import 'package:integrador/features/home/ui/providers/files_provider.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:provider/provider.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validar
        final validation = await InputValidators.validatePdfFile(file);
        if (validation != null) {
          setState(() => _error = validation);
          return;
        }

        setState(() {
          _selectedFile = file;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Error al seleccionar archivo: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
    });

    try {
      final uploadService = UploadService();
      final uploadFile = UploadFile(
        name: _selectedFile!.name,
        file: kIsWeb
            ? null
            : _selectedFile!.path != null
            ? File(_selectedFile!.path!)
            : null,
        bytes: _selectedFile!.bytes,
      );

      AppLogger.uploadStart(_selectedFile!.name, _selectedFile!.size);

      await uploadService.uploadDocument(
        file: uploadFile,
        onSendProgress: (sent, total) {
          setState(() => _uploadProgress = sent / total);
          AppLogger.uploadProgress(_selectedFile!.name, sent, total);
        },
      );

      AppLogger.uploadSuccess(_selectedFile!.name);

      if (mounted) {
        // Actualizar lista de archivos
        context.read<FilesProvider>().loadFiles();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_selectedFile!.name} subido exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Volver a home
        context.go(AppRoutes.homePath);
      }
    } catch (e) {
      AppLogger.uploadError(_selectedFile!.name, e.toString());
      setState(() {
        _error = e.toString();
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Cargar Documento',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono
            Center(
              child: Icon(
                Icons.cloud_upload_rounded,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Sube tus recursos educativos',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'PDF, DOCX o TXT - Máximo 50MB',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Botón de selección
            if (_selectedFile == null)
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Seleccionar Archivo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else
              _buildFilePreview(),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_isUploading)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 12),
                    Text(
                      'Subiendo ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final sizeMB = (_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.description, size: 40, color: AppTheme.primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFile!.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$sizeMB MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isUploading)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _error = null;
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFile,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Subir Documento'),
            ),
          ],
        ),
      ),
    );
  }
}
