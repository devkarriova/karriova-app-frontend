import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Education section - displays educational background
class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual data from state management
    final List<EducationItem> educationItems = [
      EducationItem(
        degree: 'B.Tech in Computer Science',
        institution: 'Indian Institute of Technology, Bombay',
        period: '2022 - 2026',
        grade: '8.9/10',
        achievements: [
          'Dean\'s List 2023',
          'Best Project Award',
        ],
      ),
    ];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...educationItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EducationCard(item: item),
                ),
              ),
              const SizedBox(height: 60), // Space for floating button
            ],
          ),
        ),
        // Floating Add Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              // TODO: Navigate to add education page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add education functionality coming soon'),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Education card widget
class EducationCard extends StatelessWidget {
  final EducationItem item;

  const EducationCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Section - Institution Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Degree
                    Text(
                      item.degree,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Institution
                    Text(
                      item.institution,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Period
                    Text(
                      item.period,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            Container(
              width: 1,
              color: AppColors.divider,
            ),

            // Right Section - Achievements & Grade
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grade Badge
                    if (item.grade != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.grade!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Achievements Label
                    const Text(
                      'Achievements:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Achievements List
                    ...item.achievements.map(
                      (achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                achievement,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Education item model
class EducationItem {
  final String degree;
  final String institution;
  final String period;
  final String? grade;
  final List<String> achievements;

  EducationItem({
    required this.degree,
    required this.institution,
    required this.period,
    this.grade,
    required this.achievements,
  });
}
