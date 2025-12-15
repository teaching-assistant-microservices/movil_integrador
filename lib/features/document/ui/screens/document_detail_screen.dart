// ========================================
// PANTALLA 3: DocumentDetailScreen
// lib/features/document/ui/screens/document_detail_screen.dart
// ========================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/common/widgets/detail_scaffold.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/features/home/ui/providers/files_provider.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  Map<String, dynamic>? _fileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocumentDetails();
  }

  Future<void> _loadDocumentDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filesProvider = context.read<FilesProvider>();

      // Obtener info del archivo
      final file = await filesProvider.getFileById(widget.documentId);

      setState(() {
        _fileData = file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const DetailScaffold(
        title: 'Detalles',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return DetailScaffold(
        title: 'Error',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadDocumentDetails,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final filename = _fileData?['filename'] ?? 'Sin nombre';
    final status = _fileData?['status'] ?? 'PENDING';
    final size = _fileData?['size'] ?? 0;
    final createdAt = _fileData?['createdAt'] ?? '';

    return DetailScaffold(
      title: 'Detalles del Documento',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Icono y nombre
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  filename,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Info general
          _buildInfoCard(
            context,
            title: 'Información General',
            items: [
              _InfoItem(
                'Tamaño',
                '${(size / (1024 * 1024)).toStringAsFixed(2)} MB',
              ),
              _InfoItem('Estado', status),
              _InfoItem(
                'Fecha de carga',
                createdAt.isNotEmpty
                    ? timeago.format(DateTime.parse(createdAt), locale: 'es')
                    : 'Desconocida',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Acciones
          ElevatedButton.icon(
            onPressed: () {
              context.go(AppRoutes.assistantPath);
              // Pre-cargar pregunta sobre el documento
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Preguntar sobre este documento'),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar documento'),
                  content: Text(
                    '¿Eliminar "$filename"? Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await context.read<FilesProvider>().deleteFile(
                  widget.documentId,
                );
                if (mounted) {
                  context.go(AppRoutes.explorePath);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Documento eliminado'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar documento'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<_InfoItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        item.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}
