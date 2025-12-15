// lib/features/home/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/features/home/ui/providers/files_provider.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());

    // Cargar archivos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilesProvider>().loadFiles();
    });
  }

  Future<void> _refreshFiles() async {
    await context.read<FilesProvider>().loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Inicio',
      currentNavIndex: 0,
      body: RefreshIndicator(
        onRefresh: _refreshFiles,
        child: Consumer<FilesProvider>(
          builder: (context, filesProvider, child) {
            if (filesProvider.isLoading && filesProvider.files.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (filesProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar archivos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      filesProvider.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshFiles,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // Header con botón de carga
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saludo
                        Text(
                          'Hola, Docente 👋',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestiona tus recursos educativos',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                        const SizedBox(height: 24),

                        // Botón principal de carga
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.uploadDocumentPath),
                            icon: const Icon(
                              Icons.cloud_upload_rounded,
                              size: 28,
                            ),
                            label: const Text('Cargar Nuevo Documento'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Información de límites
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Archivos válidos: PDF, DOCX, TXT | Máx: 50MB',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de documentos recientes
                if (filesProvider.files.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState(context))
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Documentos Recientes',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.explorePath),
                                child: const Text('Ver todos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final file = filesProvider.files[index];
                        return _buildFileCard(context, file);
                      },
                      childCount: filesProvider.files.length > 5
                          ? 5
                          : filesProvider.files.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 96,
              color: AppTheme.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes documentos aún',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza cargando tu primer recurso educativo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.uploadDocumentPath),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Cargar Primer Documento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, dynamic file) {
    final String status = file['status'] ?? 'PENDING';
    final String filename = file['filename'] ?? 'Sin nombre';
    final String createdAt = file['createdAt'] ?? '';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Listo';
        break;
      case 'PROCESSING':
        statusColor = AppTheme.processingColor;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Procesando';
        break;
      case 'FAILED':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.error;
        statusText = 'Error';
        break;
      default:
        statusColor = AppTheme.processingColor;
        statusIcon = Icons.pending;
        statusText = 'Pendiente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.getDocumentDetailPath(file['id']));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt.isNotEmpty
                          ? timeago.format(
                              DateTime.parse(createdAt),
                              locale: 'es',
                            )
                          : 'Fecha desconocida',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
