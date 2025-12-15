import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:integrador/core/router/routes.dart';

class MessageBubbleWidget extends StatelessWidget {
  final String content;
  final bool isUser;
  final List<dynamic> sources;
  final bool isLoading;

  const MessageBubbleWidget({
    super.key,
    required this.content,
    required this.isUser,
    this.sources = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textPrimaryColor,
                      ),
                    )
                  : Text(
                      content,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : AppTheme.textPrimaryColor,
                        fontSize: 15,
                      ),
                    ),
            ),

            // Fuentes (solo para mensajes del asistente)
            if (!isUser && sources.isNotEmpty)
              ...sources.map((source) => _buildSource(context, source)),

            // Botón de generación de material
            if (!isUser && sources.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.generateReportPath);
                  },
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Generar material con esto'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSource(BuildContext context, dynamic source) {
    final String title = source['title'] ?? 'Documento';
    final double relevance = (source['relevance_score'] ?? 0.0) is int
        ? (source['relevance_score'] as int).toDouble()
        : source['relevance_score'] ?? 0.0;
    final int percentage = (relevance * 100).round();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
