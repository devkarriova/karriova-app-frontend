import 'package:flutter/material.dart';

/// Conversation tile widget - displays a conversation in the list
class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text('Conversation Tile - TODO: Implement'),
      subtitle: Text('Last message preview...'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('12:30 PM'),
          SizedBox(height: 4),
          CircleAvatar(
            radius: 10,
            child: Text('3', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
