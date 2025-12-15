// lib/features/assistant/ui/screens/assistant_screen.dart
// ✅ CORREGIDO - Sin streaming, funciona con provider actualizado

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/features/assistant/ui/providers/assistant_provider.dart';
import 'package:integrador/features/auth/ui/providers/auth_provider.dart';

// Widgets
import '../widgets/chat_input_widget.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/empty_state_widget.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Inicializar sesión de chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final assistantProvider = context.read<AssistantProvider>();

      // Solo inicializar si hay usuario y no hay sesión
      if (authProvider.user != null && !assistantProvider.hasSession) {
        assistantProvider.initialize(userId: authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onSendMessage(
    BuildContext context,
    String query,
    bool enableWebSearch,
  ) async {
    final provider = context.read<AssistantProvider>();

    // Llamada al provider
    await provider.sendMessage(query: query, enableWebSearch: enableWebSearch);

    _scrollToBottom();
  }

  Future<void> _onClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Historial'),
        content: const Text(
          '¿Estás seguro de eliminar todo el historial de chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      final assistantProvider = context.read<AssistantProvider>();

      if (authProvider.user != null) {
        await assistantProvider.clearHistory(userId: authProvider.user!.id);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Asistente',
      currentNavIndex: 1,
      actions: [
        // Botón de limpiar historial
        Consumer<AssistantProvider>(
          builder: (context, provider, _) {
            if (provider.messages.isEmpty) return const SizedBox.shrink();

            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _onClearHistory(context),
              tooltip: 'Limpiar historial',
            );
          },
        ),
      ],
      body: Consumer<AssistantProvider>(
        builder: (context, provider, child) {
          // Mostrar error si hay
          if (provider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              provider.clearError();
            });
          }

          return Column(
            children: [
              // Lista de mensajes
              Expanded(
                child: provider.messages.isEmpty
                    ? EmptyStateWidget(
                        onSuggestionSelected: (text) {
                          _onSendMessage(context, text, false);
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];

                          return MessageBubbleWidget(
                            content: message.content,
                            isUser: message.isUser,
                            sources: message.sources,
                            isLoading: false, // Ya no hay streaming
                          );
                        },
                      ),
              ),

              // Input Area
              ChatInputWidget(
                isLoading: provider.isLoading,
                onSend: (message, enableWebSearch) {
                  _onSendMessage(context, message, enableWebSearch);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
