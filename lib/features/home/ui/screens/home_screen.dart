// lib/features/home/ui/screens/home_screen.dart
// VERSIÓN CORREGIDA - Implementa validación completa de archivos PDF

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:integrador/core/utils/validators.dart'; // ⬅️ NUEVO IMPORT CRÍTICO
import 'package:integrador/features/home/domain/entities/upload_result_entity.dart';
import 'package:integrador/features/home/ui/providers/home_provider.dart';
import 'package:integrador/features/home/ui/widgets/document_dashboard.dart';
import 'package:integrador/features/home/ui/widgets/recent_activity_summary.dart';
import 'package:integrador/features/home/ui/widgets/upload_button.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showUploadResult(BuildContext context, UploadResultEntity result) {
    final color = result.success ? AppTheme.successColor : AppTheme.errorColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          result.message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // 🔒 CORRECCIÓN CRÍTICA: Validar archivo antes de subir
  Future<void> _handleUpload(BuildContext context) async {
    final provider = context.read<HomeProvider>();

    // Paso 1: Seleccionar archivo
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Necesario para web y validación MIME
    );

    if (result == null) return;

    final file = result.files.single;

    // 🔒 PASO 2: VALIDACIÓN COMPLETA DEL ARCHIVO
    final validationError = await InputValidators.validatePdfFile(file);

    if (validationError != null) {
      // Mostrar error de validación al usuario
      _showUploadResult(
        context,
        UploadResultEntity(success: false, message: '❌ $validationError'),
      );
      return;
    }

    // 🔒 PASO 3: Sanitizar nombre de archivo
    final sanitizedName = InputValidators.sanitizeFilename(file.name);

    // Mostrar mensaje informativo si el nombre fue modificado
    if (sanitizedName != file.name) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ℹ️ Nombre de archivo modificado por seguridad: $sanitizedName',
          ),
          backgroundColor: AppTheme.processingColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      // Paso 4: Subir archivo validado
      if (kIsWeb) {
        // WEB → Se envían los bytes
        if (file.bytes == null) {
          _showUploadResult(
            context,
            UploadResultEntity(
              success: false,
              message: 'No se pudieron leer los bytes del archivo.',
            ),
          );
          return;
        }

        await provider.uploadFile('', bytes: file.bytes, name: sanitizedName);
      } else {
        // MÓVIL → Se envía la ruta del archivo
        if (file.path == null) {
          _showUploadResult(
            context,
            UploadResultEntity(
              success: false,
              message: 'Ruta de archivo no válida en móvil.',
            ),
          );
          return;
        }

        await provider.uploadFile(file.path!, name: sanitizedName);
      }

      // Mostrar resultado
      if (provider.lastUploadResult != null) {
        _showUploadResult(context, provider.lastUploadResult!);
      } else if (provider.errorMessage != null) {
        _showUploadResult(
          context,
          UploadResultEntity(success: false, message: provider.errorMessage!),
        );
      }
    } catch (e) {
      _showUploadResult(
        context,
        UploadResultEntity(success: false, message: e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return MainScaffold(
          title: 'Inicio',
          currentNavIndex: 0,
          body: RefreshIndicator(
            onRefresh: provider.refreshData,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔒 Información de seguridad
                  if (!provider.isLoading) _SecurityInfoCard(),

                  const SizedBox(height: 16),

                  UploadButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _handleUpload(context),
                    isLoading: provider.isLoading,
                  ),
                  const SizedBox(height: 24),
                  const DocumentDashboard(),
                  const SizedBox(height: 16),
                  const RecentActivitySummary(),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Versión 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppTheme.textLightColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🔒 NUEVO WIDGET: Tarjeta informativa de seguridad
class _SecurityInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppTheme.accentTeal.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: AppTheme.accentTeal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Archivos validados: Solo PDF, máx 50MB',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
