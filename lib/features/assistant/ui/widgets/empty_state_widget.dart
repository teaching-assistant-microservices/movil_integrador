import 'package:flutter/material.dart';
import 'package:integrador/themes/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final Function(String) onSuggestionSelected;

  const EmptyStateWidget({super.key, required this.onSuggestionSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 96,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '¿Cómo puedo ayudarte hoy?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Pregunta sobre tus documentos o temas educativos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Ejemplos de preguntas
            _buildSuggestionChip('¿Qué técnicas pedagógicas tienes?'),
            const SizedBox(height: 8),
            _buildSuggestionChip('Explícame sobre aprendizaje constructivista'),
            const SizedBox(height: 8),
            _buildSuggestionChip('Crea una guía de estudio sobre fracciones'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => onSuggestionSelected(text),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: AppTheme.primaryColor),
    );
  }
}
