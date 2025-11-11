import 'package:flutter/material.dart';
import 'package:integrador/themes/app_theme.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¿Cómo puedo ayudarte hoy?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Pregúntame sobre tus documentos pedagógicos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _SuggestedQuestions(),
          ],
        ),
      ),
    );
  }
}

class _SuggestedQuestions extends StatelessWidget {
  final List<String> questions = const [
    '¿Qué estrategias de enseñanza puedo usar?',
    'Resumen de materiales de matemáticas',
    '¿Cómo evaluar el aprendizaje?',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Preguntas sugeridas:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
        const SizedBox(height: 12),
        ...questions.map((question) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SuggestionChip(question: question),
            )),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String question;

  const _SuggestionChip({required this.question});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aquí se enviaría la pregunta sugerida
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.textLightColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: AppTheme.accentTeal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
