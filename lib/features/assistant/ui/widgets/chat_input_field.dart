// lib/features/assistant/ui/widgets/chat_input_field.dart
// VERSIÓN CORREGIDA - Implementa validación de longitud y feedback visual

import 'package:flutter/material.dart';
import 'package:integrador/core/utils/validators.dart'; // ⬅️ NUEVO IMPORT
import 'package:integrador/themes/app_theme.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  int _currentLength = 0;

  // 🔒 CORRECCIÓN 1: Límite de caracteres
  final int _maxLength = InputValidators.MAX_MESSAGE_LENGTH;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      final text = _controller.text.trim();
      _hasText = text.isNotEmpty;
      _currentLength = _controller.text.length;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();

    // 🔒 CORRECCIÓN 2: Validar antes de enviar
    if (text.isEmpty || widget.isLoading) return;

    // 🔒 CORRECCIÓN 3: Verificar longitud
    if (text.length > _maxLength) {
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mensaje demasiado largo. Máximo $_maxLength caracteres.',
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Enviar mensaje (será sanitizado en el provider)
    widget.onSendMessage(text);
    _controller.clear();
    setState(() {
      _hasText = false;
      _currentLength = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 CORRECCIÓN 4: Calcular si está cerca del límite
    final isNearLimit = _currentLength > _maxLength * 0.9; // 90% del límite
    final isOverLimit = _currentLength > _maxLength;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔒 CORRECCIÓN 5: Indicador de longitud (solo visible cerca del límite)
            if (isNearLimit)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      isOverLimit ? Icons.warning_amber : Icons.info_outline,
                      size: 16,
                      color: isOverLimit
                          ? AppTheme.errorColor
                          : AppTheme.processingColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_currentLength / $_maxLength caracteres',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverLimit
                            ? AppTheme.errorColor
                            : AppTheme.textSecondaryColor,
                        fontWeight: isOverLimit
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

            // Campo de entrada
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      // 🔒 CORRECCIÓN 6: Borde rojo si excede límite
                      border: isOverLimit
                          ? Border.all(color: AppTheme.errorColor, width: 2)
                          : null,
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      // 🔒 CORRECCIÓN 7: Limitar entrada en UI
                      maxLength: _maxLength,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            // No mostrar contador predeterminado
                            return const SizedBox.shrink();
                          },
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    // 🔒 CORRECCIÓN 8: Deshabilitar botón si excede límite
                    color: _hasText && !widget.isLoading && !isOverLimit
                        ? AppTheme.primaryColor
                        : AppTheme.textLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send, size: 22),
                    color: Colors.white,
                    onPressed: _hasText && !widget.isLoading && !isOverLimit
                        ? _handleSend
                        : null,
                    tooltip: isOverLimit
                        ? 'Mensaje demasiado largo'
                        : 'Enviar mensaje',
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
