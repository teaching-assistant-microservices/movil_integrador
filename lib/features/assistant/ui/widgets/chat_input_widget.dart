import 'package:flutter/material.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:integrador/core/utils/validators.dart';

class ChatInputWidget extends StatefulWidget {
  final bool isLoading;
  final Function(String message, bool enableWebSearch) onSend;

  const ChatInputWidget({
    super.key,
    required this.isLoading,
    required this.onSend,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final _messageController = TextEditingController();
  bool _enableWebSearch = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Usamos el validador original aquí
    final sanitizedMessage = InputValidators.sanitizeChatMessage(message);

    // Enviamos al padre
    widget.onSend(sanitizedMessage, _enableWebSearch);

    // Limpiamos
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox de web search
            Row(
              children: [
                Checkbox(
                  value: _enableWebSearch,
                  onChanged: widget.isLoading
                      ? null
                      : (value) {
                          setState(() => _enableWebSearch = value ?? false);
                        },
                ),
                Expanded(
                  child: Text(
                    '🌐 Buscar en web si es necesario',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Input field
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: widget.isLoading ? null : (_) => _handleSend(),
                  ),
                ),

                const SizedBox(width: 12),

                // Botón de envío
                CircleAvatar(
                  radius: 24,
                  backgroundColor: widget.isLoading
                      ? AppTheme.textSecondaryColor
                      : AppTheme.primaryColor,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: Colors.white,
                          onPressed: _handleSend,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
