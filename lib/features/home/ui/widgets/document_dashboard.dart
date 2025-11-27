import 'package:flutter/material.dart';
import 'package:integrador/core/mocks/documents_mock_data.dart';
import 'package:integrador/themes/app_theme.dart';

class DocumentDashboard extends StatelessWidget {
  const DocumentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = DocumentsMockData.mockDocuments;

    return Card(
      elevation: 3,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Documentos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${documents.length} archivos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusChip(
                  label: 'Listos',
                  count: documents
                      .where((d) => d['status'] == 'COMPLETED')
                      .length,
                  color: AppTheme.successColor,
                ),
                _StatusChip(
                  label: 'Procesando',
                  count: documents
                      .where((d) => d['status'] == 'PROCESSING')
                      .length,
                  color: AppTheme.processingColor,
                ),
                _StatusChip(
                  label: 'Errores',
                  count: documents.where((d) => d['status'] == 'FAILED').length,
                  color: AppTheme.errorColor,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Recent Documents
            ...documents.take(3).map((doc) => _DocumentTile(doc: doc)),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // TODO: Navegar a lista completa
              },
              child: const Text('Ver todos los documentos →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final Map<String, dynamic> doc;

  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppTheme.getCategoryColor(doc['primaryCategory']),
        child: Icon(
          _getCategoryIcon(doc['primaryCategory']),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        doc['title'],
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${doc['primaryCategory']} • ${_formatDate(doc['uploadedAt'])}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: _StatusBadge(status: doc['status']),
      onTap: () {
        // TODO: Navegar a detalle del documento
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Matemáticas':
        return Icons.calculate;
      case 'Pedagogía':
        return Icons.school;
      case 'Metodología':
        return Icons.psychology;
      default:
        return Icons.description;
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'COMPLETED':
        color = AppTheme.successColor;
        label = 'Listo';
        break;
      case 'PROCESSING':
        color = AppTheme.processingColor;
        label = 'Procesando';
        break;
      case 'FAILED':
        color = AppTheme.errorColor;
        label = 'Error';
        break;
      default:
        color = AppTheme.textSecondaryColor;
        label = 'Desconocido';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
