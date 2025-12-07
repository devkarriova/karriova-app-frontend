import 'package:flutter/material.dart';

/// About section - displays user bio and career goals
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Card
          _buildCard(
            title: 'About',
            onEdit: () {
              // TODO: Handle edit about
            },
            child: const Text(
              'Passionate about leveraging AI and Machine Learning to solve real-world problems. '
              'Currently pursuing B.Tech in Computer Science at IIT Bombay with a CGPA of 8.9. '
              'Active member of the Coding Club and Robotics Society.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),

          const SizedBox(height: 16),

          // Career Goals Card
          _buildCard(
            title: 'Career Goals',
            onEdit: () {
              // TODO: Handle edit career goals
            },
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildGoalChip('Software Engineering at FAANG'),
                _buildGoalChip('AI Research'),
                _buildGoalChip('Startup Founder'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Edit Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                onPressed: onEdit,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                iconSize: 16,
                color: Colors.grey[600],
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildGoalChip(String label) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_border, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelPadding: EdgeInsets.zero,
    );
  }
}
