import 'package:flutter/material.dart';

/// Achievements section - displays user achievements
class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Achievements Section - TODO: Implement with data'),
        ],
      ),
    );
  }
}
