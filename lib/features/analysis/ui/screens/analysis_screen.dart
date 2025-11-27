// lib/features/analysis/ui/screens/analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/core/mocks/analysis_mock_data.dart';
import 'package:integrador/themes/app_theme.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clusterData = AnalysisMockData.mockClusters();
    final metrics = AnalysisMockData.mockMetrics();

    return MainScaffold(
      title: 'Análisis',
      currentNavIndex: 3,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Métricas Generales
            _MetricsCard(metrics: metrics),

            const SizedBox(height: 16),

            // Título de Clusters
            Text(
              'Agrupaciones Inteligentes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Documentos organizados por similitud semántica',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Lista de Clusters
            ...((clusterData['clusters'] as List).map((cluster) {
              return _ClusterCard(cluster: cluster);
            })),

            const SizedBox(height: 16),

            // Métricas de Calidad
            _QualityMetricsCard(
              silhouetteScore: clusterData['silhouette_score'],
              updatedAt: clusterData['updated_at'],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const _MetricsCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricItem(
                  label: 'Total Documentos',
                  value: metrics['total_documents'].toString(),
                  icon: Icons.description,
                  color: AppTheme.primaryColor,
                ),
                _MetricItem(
                  label: 'Completados',
                  value: metrics['processing_status']['completed'].toString(),
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                ),
                _MetricItem(
                  label: 'Procesando',
                  value: metrics['processing_status']['processing'].toString(),
                  icon: Icons.hourglass_empty,
                  color: AppTheme.processingColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ClusterCard extends StatelessWidget {
  final Map<String, dynamic> cluster;

  const _ClusterCard({required this.cluster});

  @override
  Widget build(BuildContext context) {
    final keywords = cluster['top_keywords'] as List;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle del cluster
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        cluster['cluster_id'].toString(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cluster['label'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cluster['document_count']} documentos',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Coherence Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(cluster['coherence_score'] * 100).toInt()}%',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Keywords
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: keywords.take(4).map((keyword) {
                  return Chip(
                    label: Text(keyword, style: const TextStyle(fontSize: 12)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityMetricsCard extends StatelessWidget {
  final double silhouetteScore;
  final String updatedAt;

  const _QualityMetricsCard({
    required this.silhouetteScore,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Calidad del Clustering',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Silhouette Score:',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                Text(
                  silhouetteScore.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: silhouetteScore,
              backgroundColor: AppTheme.textLightColor.withOpacity(0.2),
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Última actualización: ${_formatDate(updatedAt)}',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
