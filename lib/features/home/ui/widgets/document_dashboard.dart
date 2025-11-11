import 'package:flutter/material.dart';
import 'package:integrador/themes/app_theme.dart';

class DocumentDashboard extends StatelessWidget {
  const DocumentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Dashboard de Documentos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Aquí se mostrarán los documentos y sus estados (Próximamente)...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
