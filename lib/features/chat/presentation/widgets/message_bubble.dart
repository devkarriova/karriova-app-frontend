import 'package:flutter/material.dart';

/// Message bubble widget - displays a single message
class MessageBubble extends StatelessWidget {
  final bool isSentByMe;

  const MessageBubble({
    super.key,
    this.isSentByMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Message Bubble - TODO: Implement',
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
