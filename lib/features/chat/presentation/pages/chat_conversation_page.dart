import 'package:flutter/material.dart';

/// Chat conversation page - displays messages in a conversation
class ChatConversationPage extends StatelessWidget {
  final String conversationId;
  final String otherUserId;

  const ChatConversationPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: const Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Chat Conversation Page - TODO: Implement with custom design'),
            ),
          ),
          // TODO: Add message input field
        ],
      ),
    );
  }
}
