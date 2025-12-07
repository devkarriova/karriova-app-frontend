import 'package:flutter/material.dart';

/// Chat list page - displays list of conversations
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: const Center(
        child: Text('Chat List Page - TODO: Implement with custom design'),
      ),
    );
  }
}
