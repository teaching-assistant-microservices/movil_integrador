import 'package:flutter/material.dart';
import 'package:integrador/features/assistant/ui/providers/assistant_provider.dart';
import 'package:provider/provider.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/features/assistant/ui/widgets/chat_empty_state.dart';
import 'package:integrador/features/assistant/ui/widgets/chat_input_field.dart';
import 'package:integrador/features/assistant/ui/widgets/chat_message_bubble.dart';
import 'package:integrador/features/assistant/ui/widgets/typing_indicator.dart';


class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSendMessage(String text) {
    context.read<AssistantProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar conversación'),
        content:
            const Text('¿Estás seguro de que quieres borrar toda la conversación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AssistantProvider>().clearChat();
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Asistente',
      currentNavIndex: 1,
      actions: [
        Consumer<AssistantProvider>(
          builder: (context, provider, child) {
            if (provider.messages.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _clearChat,
                tooltip: 'Limpiar conversación',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
      body: Consumer<AssistantProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Lista de mensajes
              Expanded(
                child: provider.messages.isEmpty
                    ? const ChatEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length && provider.isTyping) {
                            return const TypingIndicator();
                          }

                          final message = provider.messages[index];
                          return ChatMessageBubble(
                            message: message.message,
                            isUser: message.isUser,
                            timestamp: message.timestamp,
                            documentReference: message.documentReference,
                          );
                        },
                      ),
              ),

              // Campo de entrada
              ChatInputField(
                onSendMessage: _handleSendMessage,
                isLoading: provider.isTyping,
              ),
            ],
          );
        },
      ),
    );
  }
}