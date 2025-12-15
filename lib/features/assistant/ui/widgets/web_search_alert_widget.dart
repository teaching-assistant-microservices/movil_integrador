import 'package:flutter/material.dart';

class WebSearchAlertWidget extends StatelessWidget {
  final String? message;
  final VoidCallback onDismiss;
  final VoidCallback onSearch;

  const WebSearchAlertWidget({
    super.key,
    this.message,
    required this.onDismiss,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBC02D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: const Color(0xFFF57F17), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No encontré resultados relevantes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Puedo buscar en internet. ¿Deseas continuar?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF57F17)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSearch,
                  icon: const Icon(Icons.public),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBC02D),
                    foregroundColor: const Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
